# TODO: Split this file: one part for providers, one for consumers!
class Api::ResourcesController < ApiController
  before_filter :ensure_klass
  before_filter :ensure_instance

  # Creates resource consumer on provider.
  def create
    instance.add_resource_consumer(params[:service], params[:realm])
    render(:json => {:resource => JSON.generate(instance.resourceable_hash)})
  end

  # Updates resource on consumer.
  def update
    begin
      instance.update_resource_attributes(params['resource'])
      render :nothing => true
    rescue => e
      Rails.logger.error "Error while updating resource consumer:\n#{e.inspect}"
      render(:json => {:error => e}, :status => :bad_request)
    end
  end

  # Removes a resource consumer from provider or consumer.
  def destroy
    if provider?
      instance.remove_resource_consumer(params[:service], params[:realm])
    else
      instance.destroy_without_callback
    end
    render(:nothing => true)
  end

  private

  def klass
    @klass ||= begin
      params[:klass].classify.constantize
    rescue => e
      @klass_error = e
    end
  end

  def klass_with_realm?
    @is_klass_with_realm ||= klass.instance_methods.include?('realm_uuid')
  end

  def instance
    @instance ||= begin
      results = klass.where(:uuid => params[:uuid])
      if klass_with_realm?
        results = results.and(:realm_uuid => params[:realm])
      end
      results.first
    end
  end

  def no_instance_required?
    %w[create].include?(action_name) and !provider?
  end

  def ensure_klass
    if !klass or @klass_error
      render(:json => {:error => @klass_error}, :status => :bad_request)
    end
  end

  def provider?
    @is_provider ||= klass.instance_methods.include?('resource_consumers')
  end

  def ensure_instance
    unless instance
      render(:json => {:error => "#{klass} #{params[:uuid]} not found"}, :status => :not_found)
    end
  end
end
