class SurveyMailer < ApplicationMailer

  def give_feedback(project_configuration, issue)
    mail(to: issue['reporter']['email'], subject: project_configuration.subject)
  end

  def test_feedback(jwt_user, project_configuration)
    give_feedback(project_configuration, {
      reporter: {
        email: jwt_user.jwt_user_info.email
      }
    })
  end

end
