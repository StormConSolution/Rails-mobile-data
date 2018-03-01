/* eslint-env jest */

import { generateSdkFilter } from '../../../explore/sdkFilterBuilder.utils';

describe('buildSdkFilters', () => {
  it('should create a filter for an sdk category install event anytime', () => {
    const filter = {
      sdks: [{
        id: 114,
        name: 'Analytics',
        type: 'sdkCategory',
        platform: 'ios',
        sdks: [12, 56, 234, 734, 34, 5],
      }],
      eventType: 'install',
      dateRange: 'anytime',
      dates: ['2017-10-01', '2017-11-01'],
      operator: 'any',
    };

    const expected = {
      operator: 'union',
      inputs: [
        {
          object: 'sdk_event',
          operator: 'filter',
          predicates: [
            ['type', 'install'],
            ['sdk_ids', [12, 56, 234, 734, 34, 5]],
            ['platform', 'ios'],
          ],
        },
      ],
    };

    const sdkFilter = generateSdkFilter(filter);

    expect(sdkFilter).toMatchObject(expected);
    expect(sdkFilter.inputs).toEqual(expected.inputs);
    expect(sdkFilter.inputs[0].predicates).toEqual(expected.inputs[0].predicates);
    expect(sdkFilter.inputs[0].predicates[1][1]).toEqual(expected.inputs[0].predicates[1][1]);
  });
});
