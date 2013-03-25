class Restaurant < ActiveRecord::Base
  has_and_belongs_to_many :features
  serialize :coordinates, Array
  serialize :menu, Array
  serialize :opening, Hash
  
  def content
    content = '<div class="prehrana-info"><h4>' + name + '</h4>'
    content += '<address>' + address + '</address>'
    content += '<p><strong>' + price + '</strong></p>'
    content += '<ul>'
    content += '<li>Delavnik: ' + opening['Week'][0] + ' - ' + opening['Week'][1] + '</li>'
    if opening['Saturday']
      content += '<li>Sobota: ' + opening['Saturday'][0] + ' - ' + opening['Saturday'][1] + '</li>'
    else
      content += '<li>Sobota: zaprto</li>'
    end
    if opening['Sunday']
      content += '<li>Nedelja: ' + opening['Sunday'][0] + ' - ' + opening['Sunday'][1] + '</li>'
    else
      content += '<li>Nedelja: zaprto</li>'
    end
    if opening['Notes']
      content += '<li>Opombe: ' + opening['Notes'] + '</li>'
    end
    content += '</ul>'
    content += '<p>Storitve: ' + features.map(&:title).join(', ') + '</p>'
    if menu.any?
      content += '<p><a href="#" class="load-menu" data-restaurant="' + id.to_s + '">' + 'Jedilnik</a></p>'
    end
    return content
  end
end