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

# XML -> SQL
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
# [Syntaxe wiki](https://www.wikiterritorial.cnfpt.fr/xwiki/bin/view/XWiki/XWikiSyntax)

Les objets wiki de la page Georges Brassens :

```
SELECT page_id, unnest(regexp_matches(content, '\[\[([^\]]*)\]\]', 'g')) AS terme FROM "public"."wikisql" WHERE page_id='1333'
UNION
SELECT page_id, unnest(regexp_matches(content, '\{\{([^\}]*)\}\}', 'g')) AS terme FROM "public"."wikisql" WHERE page_id='1333'
```

Pages les plus liées :

Test :
```
SELECT page_id, unnest(regexp_matches(content, '\[\[([^\]\|]*)', 'g')) AS terme FROM "public"."wikisql" WHERE page_id='1333';
```
Création de Table :
```
CREATE UNLOGGED TABLE page_links_to AS SELECT page_id, unnest(regexp_matches(content, '\[\[([^\]\|]*)', 'g')) AS terme FROM "public"."wikisql" ;
```
Combien de liens : 147,607,584
Il faut créer un index :
```
CREATE INDEX links_idx
ON page_links_to USING HASH (terme) ;
```
Les pages les plus citéees :
```
SELECT terme, count(distinct page_id) 
FROM page_links_to 
GROUP BY terme 
ORDER BY count(distinct page_id)  
DESC
LIMIT 50
```
| **terme**                                                     | **count** |
|--------------------------------------------------------------:|----------:|
| France                                                        | 264114    |
| États-Unis                                                    | 247383    |
| Paris                                                         | 133868    |
| espèce                                                        | 89863     |
| Allemagne                                                     | 87484     |
| Canada                                                        | 73308     |
| Royaume-Uni                                                   | 72440     |
| Seconde Guerre mondiale                                       | 70996     |
| Pologne                                                       | 70077     |
| Italie                                                        | 68616     |
| Famille (biologie)                                            | 66870     |
| Europe                                                        | 66047     |
| Espagne                                                       | 62015     |
| football                                                      | 58092     |
| Belgique                                                      | 57747     |
| Londres                                                       | 57563     |
| Commune (France)                                              | 55415     |
| New York                                                      | 52102     |
| Japon                                                         | 51938     |
| Région française                                              | 49348     |
| Angleterre                                                    | 48126     |
| département français                                          | 46450     |
| Département français                                          | 46168     |
| Jour julien                                                   | 45260     |
| Première Guerre mondiale                                      | 44799     |
| Centre des planètes mineures                                  | 43701     |
| Année julienne                                                | 43218     |
| Ceinture d'astéroïdes                                         | 42538     |
| Catégorie:Astéroïde de la ceinture principale                 | 42443     |
| Québec                                                        | 41912     |
| écliptique                                                    | 41407     |
| grand axe                                                     | 41295     |
| inclinaison orbitale                                          | 40924     |
| Institut national de la statistique et des études économiques | 40685     |
| excentricité orbitale                                         | 40594     |
| ceinture d'astéroïdes                                         | 40008     |
| Russie                                                        | 39769     |
| anglais                                                       | 37992     |
| Pays-Bas                                                      | 37752     |
| Californie                                                    | 37673     |
| Union européenne                                              | 36663     |
| Suisse                                                        | 35570     |
| Australie                                                     | 35311     |
| Rome                                                          | 34636     |
| base de données                                               | 34618     |
| Institut national de l'information géographique et forestière | 34167     |
| famille (biologie)                                            | 33818     |
| 2006                                                          | 33267     |
| biophysique                                                   | 33215     |
| Corine Land Cover                                             | 33088     |

# Parsing des Infobox

```
SELECT content FROM wikisql WHERE title='Cécile Helle'
```

# Découpage par ligne

```
SELECT unnest(string_to_array(content, E'\n')) FROM wikisql WHERE title='Cécile Helle'
```
# Découpage sur "="
```
WITH lines AS (SELECT unnest(string_to_array(content, E'\n')) as line FROM wikisql WHERE title='Cécile Helle'),
attval AS (SELECT string_to_array(line, E'=') x FROM lines)
SELECT x[1] as attribute, x[2] as value FROM attval
```

