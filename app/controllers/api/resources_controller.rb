# TODO: Split this file: one part for providers, one for consumers?
class Api::ResourcesController < ApiController
  before_filter :ensure_klass
  before_filter :find_instance

  # Creates resource consumer on provider.
  def create
    @instance.add_resource_consumer(params['service'], params['realm'])
    render(:json => {:resource => JSON.generate(@instance.resourceable_hash)})
  end

  # Updates resource on consumer.
  def update
    begin
      @instance.update_resource_attributes(params["resource"])
      render :nothing => true
    rescue => e
      Rails.logger.error 'Error while updating resource consumer: '+e.inspect
      render(:json => {:error => e}, :status => :bad_request)
    end
  end

  # Removes a resource consumer from provider
  # or remove a resource from a consumer.
  def destroy
    if @instance.respond_to?(:resource_consumers)
      @instance.remove_resource_consumer(params['service'], params['realm'])
    else
      @instance.destroy_without_callback
    end
    render :nothing => true
  end

  private

  def ensure_klass
    begin
      @klass = params[:klass].classify.constantize
    rescue => e
      render :json => {:error => e}, :status => :bad_request
    end
  end

  def find_instance
    result = @klass.where(:uuid => params[:uuid])
    if @klass.new.respond_to?(:realm_uuid)
      result.and(:realm_uuid => params[:realm])
    end
    @instance = result.first or render(:json => {:error => "#{@klass} #{params[:uuid]} not found"}, :status => :not_found)
  end
end
