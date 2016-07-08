class ProjectConfigurationsController < ApplicationController
  include AtlassianJwtAuthentication

  # will respond with head(:unauthorized) if verification fails
  before_action only: [:edit, :update] do |controller|
    controller.send(:verify_jwt, PluginKeyService::PLUGIN_KEY)
  end

  before_action :load_project_configuration

  def edit
    @project_configuration ||= create_project_configuration
  end

  def update
    @project_configuration.update(params.require(:project_configuration)
                    .permit([:product_name, :language, :reply_to, :from, :subject, :introduction]))

    flash[:notice] = 'Configuration was saved!'

    redirect_to(edit_project_configuration_url(@project_configuration, jwt: params[:jwt]))
  end

  def load_project_configuration
    @project_configuration ||= current_jwt_auth.project_configurations.find_by(params.permit(:project_id))
  end

  private

  def create_project_configuration
    user_email = rest_api_call(:get, '/rest/api/2/myself')
    if user_email.success?
      JwtUserInfo.create!(jwt_user_id: current_jwt_user.id,
                          email: user_email.data['emailAddress'],
                          time_zone: user_email.data['timeZone'])
    end

    configuration = ProjectConfiguration.new(jwt_token: current_jwt_auth, project_id: params[:project_id],
                             from: current_jwt_user.display_name,
                             reply_to: current_jwt_user.jwt_user_info.email)

    configuration.save!(validate: false)

    configuration
  end
end