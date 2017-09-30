# https://github.com/elastic/elasticsearch-docker
FROM docker.elastic.co/elasticsearch/elasticsearch:5.6.1

# Add your elasticsearch plugins setup here
# Example: RUN elasticsearch-plugin install analysis-icu

RUN elasticsearch-plugin install -b distfiles.compuscene.net/elasticsearch/elasticsearch-prometheus-exporter-5.6.2.0.zip
