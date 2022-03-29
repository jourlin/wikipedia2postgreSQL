# combien de pages ? 
```
SELECT count(distinct id) FROM wiki;
```
# Index sur les titres 
```
CREATE INDEX title_idx
ON wiki USING BTREE 
    (cast((xpath('/page/title/text()', data))[1] as text)) ;
```
# Observation du "code source"
```
SELECT data
FROM wiki 
WHERE (xpath('/page/title/text()', data))[1]::text='Georges Brassens'
```
# XML -> SQL
```
CREATE UNLOGGED TABLE wikisql AS
SELECT 
(xpath('/page/title/text()', data))[1]::text as title,
(xpath('/page/id/text()', data))[1]::text as page_id,
(xpath('/page/revision/id/text()', data))[1]::text as rev_id,
(xpath('/page/revision/parentid/text()', data))[1]::text as rev_par_id,
(xpath('/page/revision/timestamp/text()', data))[1]::text as timestamp,
(xpath('/page/revision/contributor/username/text()', data))[1]::text as contrib_name,
(xpath('/page/revision/contributor/id/text()', data))[1]::text as contrib_id,
(xpath('/page/revision/model/text()', data))[1]::text as model,
(xpath('/page/revision/format/text()', data))[1]::text as format,
(xpath('/page/revision/text/text()', data))[1]::text as content
FROM wiki 
OFFSET 1000 LIMIT 1
```
# Ajout index & contraintes
```
DELETE from wikisql WHERE page_id IS NULL;
ALTER TABLE wikisql ADD PRIMARY KEY (page_id);
```
# Combien de contributeur uniques ?
```
SELECT count(distinct contrib_id) from wikisql
```
# Contributeurs les plus prolifiques / nb pages
```
SELECT contrib_name, contrib_id, count(distinct page_id) 
from wikisql 
GROUP BY contrib_name, contrib_id
ORDER BY count(distinct page_id) DESC
LIMIT 10
```