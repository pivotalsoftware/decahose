------------------------------------------------------------------------------------------------------
-- Fetch JSON blobs from HDFS through External Tables & PXF. Parse the data and insert
-- into HAWQ internal table.
-- Maintained by: Srivatsan Ramanujam <sramanujam@gopivotal.com>, Ronert Obst<robst@gopivotal.com>
------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------
-- 1) Define external HDFS table refercing the JSON stream
----------------------------------------------------------------------------------------

	drop external table if exists twitter.decahose_rawjson_ext cascade;
	create external table twitter.decahose_rawjson_ext
	(
		tweet_json text
	) 
	LOCATION ('pxf://hdm1.gphd.local:50070/user/vatsan/decahose/*/*/*/*?profile=HdfsTextSimple')
	FORMAT 'TEXT' (ESCAPE 'OFF');
	
----------------------------------------------------------------------------------------
-- 2) Invoke PL/Python function to parse the JSON from the tweets table
----------------------------------------------------------------------------------------

	insert into twitter.tweets
	select (cols).*
	from
	(
		select twitter.gnip_json_parse(tweet_json) as cols
		from twitter.decahose_rawjson_ext
		limit 10
	)q
	limit 10;	
	
----------------------------------------------------------------------------------------	