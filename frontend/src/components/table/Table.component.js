import React from 'react';
import PropTypes from 'prop-types';
import ReactTable, { ReactTableDefaults } from 'react-table';
import { generateColumns, totalNumPages } from 'utils/table.utils';
import { headerNames } from './redux/column.models';
import ListDropdownContainer from './containers/ListDropdown.container';
import Pagination from './components/Pagination.component';

Object.assign(ReactTableDefaults, {
  className: '-striped',
  noDataText: 'No Results',
  pageSizeOptions: [20, 50, 75, 100],
  resizable: false,
});

const Table = ({
  columns,
  isAdIntel,
  loaded,
  isManual,
  loading,
  pageNum,
  pageSize,
  requestResults,
  results,
  resultsCount,
  selectedItems,
  showColumnDropdown,
  showControls,
  sort,
  title,
  toggleAll,
  toggleItem,
  updateColumns,
}) => {
  const allSelected = selectedItems.length === results.length;
  const columnHeaders = generateColumns(columns, selectedItems, allSelected, toggleItem, toggleAll, isAdIntel);
  const pages = totalNumPages(resultsCount, pageSize)
  const minRows = loading ? 10 : 0;

  const onPageChange = (pageIndex) => {
    requestResults({
      pageNum: pageIndex,
      pageSize,
      sort: sort[0].id,
      order: sort[0].desc ? 'desc' : 'asc',
    });
  };

  const onPageSizeChange = (newSize) => {
    requestResults({
      pageNum: 0,
      pageSize: newSize,
      sort: sort[0].id,
      order: sort[0].desc ? 'desc' : 'asc',
    });
  };

  const onSortedChange = (newSort) => {
    if (isManual) {
      requestResults({
        pageNum: 0,
        pageSize,
        sort: newSort[0].id,
        order: newSort[0].desc ? 'desc' : 'asc',
      });
    }
  };

  return (
    <section className="panel panel-default table-dynamic">
      <div className="panel-heading" id="dashboardResultsTableHeading">
        <strong><i className="fa fa-list panel-icon" />{title}</strong>
        {' '}
        <span id="dashboardResultsTableHeadingNumDisplayed">
          | {resultsCount} Apps
        </span>
        <ListDropdownContainer
          selectedItems={selectedItems}
        />
      </div>
      {
        isManual ? (
          <ReactTable
            columns={columnHeaders}
            data={results}
            getPaginationProps={() => ({
              columns,
              showColumnDropdown,
              updateColumns,
            })}
            getTrProps={(state, rowInfo) => ({
              className: !rowInfo.original.appAvailable && 'faded',
            })}
            loading={loading}
            manual={isManual}
            minRows={minRows}
            onPageChange={onPageChange}
            onPageSizeChange={onPageSizeChange}
            onSortedChange={onSortedChange}
            page={pageNum}
            pages={pages}
            pageSize={pageSize}
            PaginationComponent={Pagination}
            showPaginationBottom={showControls}
            showPaginationTop={showControls}
            sorted={sort}
            style={{
              height: '750px',
            }}
          />
        ) : (
          <ReactTable
            columns={columnHeaders}
            data={results}
            defaultSorted={sort}
            loading={loading}
            minRows={0}
            showPaginationBottom={false}
            showPaginationTop={false}
          />
        )
      }
    </section>
  );
};

Table.propTypes = {
  columns: PropTypes.shape({
    App: PropTypes.oneOfType([PropTypes.string, PropTypes.bool]),
    Publisher: PropTypes.oneOfType([PropTypes.string, PropTypes.bool]),
  }).isRequired,
  isAdIntel: PropTypes.bool,
  loaded: PropTypes.bool,
  isManual: PropTypes.bool,
  loading: PropTypes.bool,
  requestResults: PropTypes.func,
  pageNum: PropTypes.number,
  pageSize: PropTypes.number,
  results: PropTypes.arrayOf(PropTypes.object).isRequired,
  selectedItems: PropTypes.arrayOf(PropTypes.shape({
    id: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
    type: PropTypes.string,
  })),
  showColumnDropdown: PropTypes.bool,
  showControls: PropTypes.bool,
  sort: PropTypes.arrayOf(PropTypes.shape({
    id: PropTypes.string,
    desc: PropTypes.bool,
  })),
  title: PropTypes.string.isRequired,
  toggleAll: PropTypes.func.isRequired,
  toggleItem: PropTypes.func.isRequired,
  resultsCount: PropTypes.number.isRequired,
  updateColumns: PropTypes.func,
};

Table.defaultProps = {
  isAdIntel: false,
  loaded: true,
  isManual: false,
  loading: false,
  requestResults: null,
  pageNum: 0,
  pageSize: 20,
  sort: [
    {
      id: headerNames.LAST_UPDATED,
      desc: true,
    },
  ],
  selectedItems: [],
  showColumnDropdown: false,
  showControls: false,
  updateColumns: null,
};

export default Table;