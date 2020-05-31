import pandas as pd
import networkx as nx

# data from https://openflights.org/data.html

# data paths
path_vertices = "data/raw/airports.dat"
path_edges = "data/raw/routes.dat"

# headers of data
header_vertices = ["id","name","city","country","iata","icao","latitude"
,"longitude","altitude","timezone","dst","tz","type","source"]
header_edges = ["airline","airline_id","source_airport","source_id"
,"destination_airport","destination_id","codeshare","stops","equipment"]

# read data
raw_vertices = pd.read_csv(path_vertices, header=None, names=header_vertices \
                            , na_values=r'\N')
raw_edges = pd.read_csv(path_edges, header=None, names=header_edges \
                            , na_values=r'\N')

# clean vertices (airports) data
    # no NAs in id
clean_vertices = raw_vertices.loc[raw_vertices.id.notnull(),:]
clean_vertices = clean_vertices[['id', 'name', 'city', 'country', 'latitude' \
                                , 'longitude', 'iata', 'icao']]

# clean edges (routes) data
    # no NAs in source/destination
clean_edges = raw_edges.loc[raw_edges.source_id.notnull() & \
                            raw_edges.destination_id.notnull(),:]
    # no loops
clean_edges = clean_edges.loc[clean_edges.source_id != \
                                clean_edges.destination_id, :]
    # keep only if vertex id is available
clean_edges = clean_edges.loc[clean_edges.source_id.isin(clean_vertices.id),:]
clean_edges = clean_edges.loc[clean_edges.destination_id.isin(clean_vertices.id),:]
clean_edges = clean_edges[['source_id','destination_id']]
clean_edges = clean_edges.astype({'source_id':'int64', 'destination_id':'int64'})

# airports as cities
clean_edges_cities = pd.merge(clean_edges, clean_vertices \
                            , how='left', left_on='source_id', right_on='id')
clean_edges_cities = clean_edges_cities.rename(columns = {'city':'source_city'})
clean_edges_cities = pd.merge(clean_edges_cities, clean_vertices \
                            , how='left', left_on='destination_id', right_on='id')
clean_edges_cities = clean_edges_cities.rename(columns = {'city':'destination_city'})
clean_edges_cities = clean_edges_cities[['source_city','destination_city']]

# create directed multigraph from data
g = nx.from_pandas_edgelist(clean_edges, source='source_id' \
                    , target='destination_id', create_using=nx.MultiDiGraph())

# create directed multigraph from data for cities
gcities = nx.from_pandas_edgelist(clean_edges_cities \
                        , source='source_city', target='destination_city' \
                        , create_using=nx.MultiDiGraph())

# create directed graph with weights
gf = nx.DiGraph()
for u,v,data in g.edges(data=True):
    w = data['weight'] if 'weight' in data else 1.0
    if gf.has_edge(u,v):
        gf[u][v]['weight'] += w
    else:
        gf.add_edge(u, v, weight=w)

# create directed graph with weights for cities
gcitiesf = nx.DiGraph()
for u,v,data in gcities.edges(data=True):
    w = data['weight'] if 'weight' in data else 1.0
    if gcitiesf.has_edge(u,v):
        gcitiesf[u][v]['weight'] += w
    else:
        gcitiesf.add_edge(u, v, weight=w)

# get pagerank of airports (no dumping factor / number of flights as weights)
prank = nx.pagerank(gf, alpha=1, max_iter=99999999, weight='weight')

# get pagerank of cities (no dumping factor / number of flights as weights)
prank_cities = nx.pagerank(gcitiesf, alpha=1, max_iter=99999999, weight='weight')

# store as DataFrame
df = pd.DataFrame({'id': list(prank.keys()), 'pagerank': list(prank.values())})
# merge with airports data
df = pd.merge(df, clean_vertices, how='inner' \
        , left_on='id', right_on='id').sort_values(by='pagerank',ascending=False)
# merge with indegree and outdegree (using multigraph)
indegree = pd.DataFrame({'id':list(dict(g.in_degree).keys()) \
                        , 'in_degree':list(dict(g.in_degree).values())})
outdegree = pd.DataFrame({'id':list(dict(g.out_degree).keys()) \
                        , 'out_degree':list(dict(g.out_degree).values())})
df_out = pd.merge(df, indegree, how='inner', left_on='id', right_on='id')
df_out = pd.merge(df_out, outdegree, how='inner', left_on='id', right_on='id')

# for cities:
# store as DataFrame
dfcities = pd.DataFrame({'city': list(prank_cities.keys()) \
                        , 'pagerank': list(prank_cities.values())})
# merge with indegree and outdegree (using multigraph)
indegree_cities = pd.DataFrame({'city':list(dict(gcities.in_degree).keys()) \
                            , 'in_degree':list(dict(gcities.in_degree).values())})
outdegree_cities = pd.DataFrame({'city':list(dict(gcities.out_degree).keys()) \
                        , 'out_degree':list(dict(gcities.out_degree).values())})
df_out_cities = pd.merge(dfcities, indegree_cities, how='inner' \
                        , left_on='city', right_on='city')
df_out_cities = pd.merge(df_out_cities, outdegree_cities, how='inner' \
        , left_on='city', right_on='city').sort_values(by='pagerank',ascending=False)

# save as csv
df_out.to_csv("data/working/pageranks.csv", index=False)
df_out_cities.to_csv("data/working/pageranks_cities.csv", index=False)
clean_vertices.to_csv("data/working/vertices.csv", index=False)
clean_edges.to_csv("data/working/edges.csv", index=False)
