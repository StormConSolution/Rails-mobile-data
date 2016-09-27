class ClearbitContact < ActiveRecord::Base
  belongs_to :website

  def self.get_contacts(query, website)
    contacts = []
    people = Clearbit::Prospector.search(query)

    people.each do |person|
      contact = {
        clearbitId: person.id,
        givenName: person.name.try(:givenName),
        familyName: person.name.try(:familyName),
        fullName: person.name.try(:fullName),
        title: person.title,
        linkedin: person.linkedin
      }

      # save as new records to DB
      if website
        clearbit_contact = ClearbitContact.find_or_create_by(website_id: website.id, clearbit_id: person.id)
        contact[:email] = clearbit_contact.email if clearbit_contact.email
        clearbit_contact.update_attributes(
                                given_name: person.name.try(:givenName), 
                                family_name: person.name.try(:familyName), 
                                full_name: person.name.try(:fullName), 
                                title: person.title, 
                                linkedin: person.linkedin)
      end
      contacts << contact
    end
    contacts
  end

  def self.get_contacts_for_websites(websites, filter)
    contacts = []
    domains = {}
    # takes up to five websites associated with company & creates array of clearbit_contacts objects
    websites.first(5).each do |url|

      # finds matching record in website table
      website = Website.find_by(url: url)
      domain = UrlHelper.url_with_domain_only(url)

      next if domains[domain]
      domains[domain] = 1

      if filter.present?
        contacts += ClearbitContact.get_contacts({'domain' => domain, 'title' => filter, 'limit' => 20}, website)
      else
        current_contacts = website ? website.clearbit_contacts.where(updated_at: Time.now-60.days..Time.now).limit(60).as_json : []

        if current_contacts.count < 60
          current_contacts += ClearbitContact.get_contacts({'domain' => domain, 'title' => 'product', 'limit' => 20}, website)
          current_contacts += ClearbitContact.get_contacts({'domain' => domain, 'limit' => 20}, website)
          current_contacts += ClearbitContact.get_contacts({'domain' => domain, 'title' => 'marketing', 'limit' => 20}, website)
        end

        contacts += current_contacts
      end
    end
    contacts.uniq! {|e| e[:clearbitId] }
    contacts
  end

  def self.get_contact_email(person_id)
    get = HTTParty.get("https://prospector.clearbit.com/v1/people/#{person_id}/email", headers: {'Authorization' => 'Bearer 229daf10e05c493613aa2159649d03b4'})
    email = JSON.load(get.response.body).try(:[], "email") || "No Email"
    if ClearbitContact.where(clearbit_id: person_id).any?
      contacts = ClearbitContact.where(clearbit_id: person_id)
      contacts.update_all(email: email) if email
    end
    email
  end

  def as_json
    {
      clearbitId: clearbit_id,
      givenName: given_name,
      familyName: family_name,
      fullName: full_name,
      title: title,
      email: email,
      linkedin: linkedin
    }
  end
end
