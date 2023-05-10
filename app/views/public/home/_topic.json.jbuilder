json.id topic.id
json.name topic.name.capitalize
json.breadcrumb topic.breadcrumb.map(&:capitalize).join(' >> ')
