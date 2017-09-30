# https://github.com/elastic/elasticsearch-docker
FROM docker.elastic.co/elasticsearch/elasticsearch:5.6.2

# Add your elasticsearch plugins setup here
# Example: RUN elasticsearch-plugin install analysis-icu

COPY ./plugins /plugins

RUN elasticsearch-plugin install file:///plugins/elasticsearch-prometheus-exporter-5.6.2.0.zip
# https://distfiles.compuscene.net/elasticsearch/elasticsearch-prometheus-exporter-5.6.2.0.zip
RUN elasticsearch-plugin install mobz/elasticsearch-head

# Site Plugins
#   install_plugin 'lukas-vlcek/bigdesk'
#   install_plugin 'mobz/elasticsearch-head'
#   install_plugin 'polyfractal/elasticsearch-inquisitor'
#   # Used in versions > ES 2.0
#   # install_plugin 'elasticsearch/cloud-aws/latest'
#   install_plugin 'elasticsearch/elasticsearch-cloud-aws/2.7.1'
#   # install_plugin 'elasticsearch/marvel-agent/latest'
#   # install_plugin 'elasticsearch/marvel/latest'
#   install_plugin 'elasticsearch/license/latest'
#   install_plugin 'lmenezes/elasticsearch-kopf/1.0'

# * java.lang.RuntimePermission accessClassInPackage.sun.misc
# * java.lang.RuntimePermission accessDeclaredMembers
# * java.lang.reflect.ReflectPermission suppressAccessChecks
