class Public::TopicsController < Public::ApplicationController



  def index
    @topic = Topic.find_by id: params[:topic_id]
    selected = params[:selected].to_s.split(',').select(&:present?)
    @selected_topics = Topic.where(id: selected)
    @topic = @topic.parent if selected.include? @topic&.id&.to_s
    query = ['true']
    query << 'name ILIKE :query' if params[:q].present?
    query << (@topic.nil? ? 'parent_id is null' : 'parent_id = :topic_id')
    @topics = Topic.where(query.join(' and '), query: "%#{params[:q]}%", topic_id: params[:topic_id])
                   .where.not(id: selected).order(:name)
  end

  def value
    selected = params[:selected].to_s.split(',').select(&:present?)
    @selected_topics = Topic.where(id: selected)
  end
end
