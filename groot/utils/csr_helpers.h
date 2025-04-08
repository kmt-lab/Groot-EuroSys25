#pragma once

namespace groot {

template<typename Vector>
void get_row_lengths_from_pointers(Vector& rowlen, const Vector& rowptr)
{
    using IndexType = typename Vector::value_type;
    thrust::transform(rowptr.begin() + 1, rowptr.end(), rowptr.begin(), rowlen.begin(), thrust::minus<IndexType>());
}

template<typename Vector>
void get_row_pointers_from_indices(Vector& row_pointers, const Vector& row_indices)
{
    using IndexType = typename Vector::value_type;
    auto policy     = get_exec_policy<Vector>();

    ASSERT(thrust::is_sorted(policy, row_indices.begin(), row_indices.end()) && "row_indices must be sorted");

    thrust::lower_bound(policy,
                        row_indices.begin(),
                        row_indices.end(),
                        thrust::counting_iterator<IndexType>(0),
                        thrust::counting_iterator<IndexType>(row_pointers.size()),
                        row_pointers.begin());
}


template<typename Vector>
void get_row_indices_from_pointers(Vector& row_indices, const Vector& row_pointers)
{
    using IndexType   = typename Vector::value_type;
    auto       policy = get_exec_policy<Vector>();
    const auto nrow   = row_pointers.size() - 1;

    thrust::for_each(policy,
                     thrust::counting_iterator<IndexType>(0),
                     thrust::counting_iterator<IndexType>(nrow),
                     FillRowIndices<IndexType>(thrust::raw_pointer_cast(row_pointers.data()),
                                               thrust::raw_pointer_cast(row_indices.data())));
}



template<typename IndexVector, typename ValueVector>
void sort_columns_per_row(IndexVector& row_indices, IndexVector& column_indices, ValueVector& values)
{
    // sort columns per row
    thrust::sort_by_key(column_indices.begin(),
                        column_indices.end(),
                        thrust::make_zip_iterator(thrust::make_tuple(row_indices.begin(), values.begin())));
    thrust::stable_sort_by_key(row_indices.begin(),
                               row_indices.end(),
                               thrust::make_zip_iterator(thrust::make_tuple(column_indices.begin(), values.begin())));
}


template<typename IndexVector, typename ValueVector>
void remove_duplicates(IndexVector& row_indices, IndexVector& column_indices, ValueVector& values)
{
    ASSERT(row_indices.size() == column_indices.size() && row_indices.size() == values.size());
    const auto nnz = row_indices.size();

    // remove duplicated edges
    auto row_col_begin = thrust::make_zip_iterator(thrust::make_tuple(row_indices.begin(), column_indices.begin()));
    thrust::sort_by_key(row_col_begin, row_col_begin + nnz, values.begin());
    auto unique_end  = thrust::unique_by_key(row_col_begin, row_col_begin + nnz, values.begin());
    auto unique_size = unique_end.first - row_col_begin;
    row_indices.resize(unique_size);
    column_indices.resize(unique_size);
    values.resize(unique_size);
}


template<typename CSR>
void sort_columns_per_row(CSR& csr)
{
    using IndexType = typename CSR::index_type;

    thrust::device_vector<IndexType> row_indices(csr.num_entries);
    get_row_indices_from_pointers(row_indices, csr.row_pointers);
    remove_duplicates(row_indices, csr.column_indices, csr.values);
    sort_columns_per_row(row_indices, csr.column_indices, csr.values);
    get_row_pointers_from_indices(csr.row_pointers, row_indices);
    csr.num_entries = row_indices.size();
}


}  // namespace groot