
DATA_LENGTH is all memory needed by table without any optional indexes. Note, that primary key hash index is included since it is mandatory. Blob tables are also included.
INDEX_LENGTH is memory used by indexes, both ordered index and secondary unique indexes.  Memory for primary ordered index if it exists is included here.


select
max(if(td.base_table_id = td.object_id, td.fq_name, '')) 'TABLE_NAME',
max(td.row_count) 'ROW_COUNT',
max(td.replica_count) 'REPLICA_COUNT',
sum(td.data_bytes) 'DATA_LENGTH',
sum(td.index_bytes) 'INDEX_LENGTH',
ceil(sum(td.data_bytes)/greatest(1,max(td.row_count))) 'DATA_LENGTH_PER_ROW',
ceil(sum(td.index_bytes)/greatest(1,max(td.row_count))) 'INDEX_LENGTH_PER_ROW',
ceil(sum(td.data_bytes)/greatest(1,max(td.replica_count)*max(td.row_count))) 'DATA_LENGTH_PER_ROW_REPLICA',
ceil(sum(td.index_bytes)/greatest(1,max(td.replica_count)*max(td.row_count))) 'INDEX_LENGTH_PER_ROW_REPLICA'
from
(select
  if (doi.parent_obj_id = 0, doi.id, doi.parent_obj_id) base_table_id,
  doi.id object_id,
  doi.fq_name,
  doi.type,
  ceil(sum(fixed_elem_count)/sum(fragment_num = 0)) 'row_count',
  sum(fragment_num = 0) 'replica_count',
  sum(if(doi.type in (1,2),
         fixed_elem_alloc_bytes - fixed_elem_free_bytes +
           var_elem_alloc_bytes - var_elem_free_bytes +
           hash_index_alloc_bytes,
         0)) 'data_bytes',
  sum(if(doi.type in (3,6),
         fixed_elem_alloc_bytes - fixed_elem_free_bytes +
           hash_index_alloc_bytes,
         0)) 'index_bytes'
from
  ndbinfo.memory_per_fragment as mpf
  join ndbinfo.dict_obj_info doi
  on mpf.table_id = doi.id
where
  doi.type in (1, 2, 3, 6)
group by
  doi.id, doi.type, doi.fq_name, doi.parent_obj_id
) td
group by
  td.base_table_id
order by
  1; 
