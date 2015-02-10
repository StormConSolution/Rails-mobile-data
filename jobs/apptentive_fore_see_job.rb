require 'csv'

class ApptentiveForeSeeJob

  def run(directory_path)
    
    srs = ScrapedResult.includes(:installations).where(scrape_job_id: 45, installations: {service_id: 226})

    results = []
    
    srs.each do |sr|
      company_name = sr.company.name
      
      result[:company] = company_name
      
      ranks = PageRankr.ranks(company_name)
      result[:alexa] = ranks[:alexa_global]
      result[:google] = ranks[:google]
      
      results << result
      
      puts result
    end
      
    results.sort_by!(|result| result[:alexa])
      
    filename = "ForeSee.csv"
    
    CSV.open(directory_path + '/' + filename, "w+") do |csv|
      csv << ['Company', 'Global Alexa Ranking', 'Google Page Rank']
      
      results.each do |result|
        line = result[:company], result[:alexa], ranks[:google]]
        csv << line
        puts line
      end
    end
    
  end

  class << self

    def run(directory_path)
      self.new.run(directory_path)
    end

  end

end