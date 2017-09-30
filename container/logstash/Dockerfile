# https://github.com/elastic/logstash-docker
FROM docker.elastic.co/logstash/logstash:5.6.1

# Add your logstash plugins setup here
# Example: RUN logstash-plugin install logstash-filter-json

RUN logstash-plugin install logstash-input-file
RUN logstash-plugin install logstash-filter-date
RUN logstash-plugin install logstash-filter-geoip
RUN logstash-plugin install logstash-filter-json
