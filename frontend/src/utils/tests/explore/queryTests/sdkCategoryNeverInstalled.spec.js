/* eslint-env jest */

import { generateSdkFilter } from '../../../explore/sdkFilterBuilder.utils';

describe('buildSdkFilters', () => {
  it('should create a filter for an sdk category never installed', () => {
    const filter = {
      sdks: [{
        id: 114,
        name: 'Analytics',
        type: 'sdkCategory',
        platform: 'ios',
        sdks: [
          [12, 'bob'],
          [56, 'joe'],
          [234, 'dan'],
          [734, 'sue'],
          [34, 'dave'],
          [5, 'jan'],
        ],
        includedSdks: [
          [12, 'bob'],
          [56, 'joe'],
          [234, 'dan'],
          [734, 'sue'],
        ],
      }],
      eventType: 'never-seen',
      dateRange: 'custom',
      dates: ['2017-10-01', '2017-11-01'],
      operator: 'any',
      installState: 'is-not-installed',
    };

    const expected = {
      operator: 'union',
      inputs: [
        {
          operator: 'intersect',
          inputs: [
            {
              operator: 'not',
              inputs: [
                {
                  object: 'sdk_event',
                  operator: 'filter',
                  predicates: [
                    ['type', 'install'],
                    ['sdk_category', 'Analytics', 'ios', [34, 5]],
                  ],
                },
              ],
            },
            {
              object: 'app',
              operator: 'filter',
              predicates: [
                ['platform', 'ios'],
              ],
            },
          ],
        },
      ],
    };

    const sdkFilter = generateSdkFilter(filter);

    expect(sdkFilter).toEqual(expected);
  });
});
