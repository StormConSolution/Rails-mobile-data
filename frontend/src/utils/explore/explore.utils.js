import { convertToTableSort } from './queryBuilder.utils';

export function formatResults (data, params, count) {
  const { page_settings: { page_size }, sort: { fields }, select: { object: resultType } } = params;
  const result = {};
  result.results = Object.values(data.pages)[0].map(x => extractPublisher(x)).map(x => mockDataEnhancer(x)); // TODO: remove eventually
  result.pageNum = parseInt(Object.keys(data.pages)[0]);
  result.pageSize = page_size;
  result.resultsCount = count;
  result.sort = convertToTableSort(fields.slice(0, fields.length - 2));
  result.resultType = resultType;

  return result;
}

export function extractPublisher (app) {
  const result = Object.assign({}, app);
  delete result.publisher_name;
  delete result.publisher_id;
  result.publisher = {
    id: app.publisher_id,
    name: app.publisher_name,
    platform: app.platform,
  };

  return result;
}

function mockDataEnhancer (app) {
  return {
    ...app,
    type: app.platform === 'ios' ? 'IosApp' : 'AndroidApp',
  };
}