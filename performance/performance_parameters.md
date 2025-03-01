## postgresql.conf performance directives

These are the recommended and typical best practices to pick suitable values for the performance configurations
of postgresql.conf. The real best practice however, is obviously specific to every particular service and must be ascertained individually:


### Memory Settings
	"shared_buffers": Set to 25% of the total system memory.
	"wal_buffers": > 3% * shared_buffers
	"work_mem": Start with 4MB and adjust based on your workload.
	"maintenance_work_mem": Set to 10% of the total system memory, up to a maximum of 1GB.
	"effective_cache_size": Generally adding Linux free+cached will give you a good idea.

### Connection Settings
	"max_connections": Start with 100 and adjust based on your workload.
	connection pooling: Use a connection pooler like PgBouncer to manage connections efficiently.

### Logging and Monitoring
	"log_min_duration_statement": Set to 500ms to log slow queries.
	"pg_stat_statements": Enable this extension to track execution statistics of all SQL statements.

### Disk I/O
	"effective_io_concurrency": Set to 2 for SSDs and 1 for HDDs.
	"maintenance_io_concurrency": A good starting point is to set it to 10 and then gradually increase it while monitoring the system's performance.
	"checkpoint_completion_target": Set to 0.9 to spread the checkpoint workload over a longer period.
	"min_parallel_table_scan_size": A good starting point is to set min_parallel_table_scan_size to 8MB and then adjust it based on your specific needs.
	"min_parallel_index_scan_size": A good starting point is to set min_parallel_index_scan_size to 512kB and then adjust it based on your specific needs. For larger indexes, you might increase this value to 1MB or higher to ensure that parallel index scans are used effectively.
	"max_prepared_transactions": A good starting point is to set max_prepared_transactions to the same value as max_connections. For example, if max_connections is set to 100, you might set max_prepared_transactions to 100 as well. This ensures that you have enough slots for all potential prepared transactions.
	"old_snapshot_threshold": A good starting point is to set old_snapshot_threshold to a value between 1 hour and 24 hours, depending on your workload and the frequency of long-running transactions. For example, you might set it to 1 hour if you have frequent long-running transactions that you want to manage more aggressively, or to 24 hours if you want to allow more time for transactions to complete.

### Replication:
	"max_wal_senders": A good starting point is to set max_wal_senders to 5-10, and then adjust based on your needs

### Workload and development dependent:
	"temp_buffers":

### CPU
	"max_worker_processes": A good general recommendation is to set max_worker_processes to match the total number of CPU cores available on your system
	"max_parallel_workers_per_gather": A good starting point is to set max_parallel_workers_per_gather to 2 and then gradually increase it while monitoring the performance. For systems with more CPU cores and higher parallel processing needs, you might set it to 4 or even higher
	"max_parallel_workers": A good starting point is to set max_parallel_workers to the number of CPU cores available on your system
