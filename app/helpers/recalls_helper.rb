module RecallsHelper
  def link_to_last_session(recall)
    session = recall.patient.last_session
    return t('cydoc.recall.no_appointment') if session.nil?
    
    return link_to session.duration_from.try(:to_date), treatment_path(session.treatment)
  end
end
