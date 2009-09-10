class MedicalCasesController < ApplicationController
  # CRUD actions
  def index
    @patient = Patient.find(params[:patient_id])
    @treatment = Treatment.find(params[:treatment_id])

    query = params[:query]
    query ||= params[:search][:query] if params[:search]

    @diagnoses = Diagnosis.paginate(:page => params['page'], :per_page => 20, :conditions => ['code LIKE :query OR text LIKE :query', {:query => "%#{query}%"}], :order => 'code')

    # Show selection list only if more than one hit
    if @diagnoses.size == 1
      params[:diagnosis_id] = @diagnoses.first.id
      create
      return
    end    
    respond_to do |format|
      format.html {
        render :action => 'select_list'
        return
      }
      format.js {
        render :update do |page|
          page.replace_html 'medical_case_search_results', :partial => 'select_list'
        end
      }
    end
  end
  alias :search :index
  
  # GET /medical_cases/new
  def new
    # TODO: generalize like this: @medical_case = Object.const_get(params[:type]).new
    @medical_case = DiagnosisCase.new
    @patient = Patient.find(params[:patient_id])
    @treatment = Treatment.find(params[:treatment_id])

    @medical_case.date = Date.today
    
    respond_to do |format|
      format.html { }
      format.js {
        render :update do |page|
          page.replace_html "treatment_#{@treatment.id}_new_medical_case", :partial => 'form'
          page['search_query'].focus
        end
      }
    end
  end

  # POST /medical_cases
  def create
    @patient = Patient.find(params[:patient_id])
    @treatment = Treatment.find(params[:treatment_id])

    diagnosis = Diagnosis.find(params[:diagnosis_id])

    # TODO: generalize like this: @medical_case = Object.const_get(params[:medical_case][:type]).new(params[:medical_case])
    @medical_case = DiagnosisCase.new(params[:medical_case])

    @medical_case.doctor = @current_doctor
    @medical_case.diagnosis = diagnosis
    @medical_case.treatment = @treatment

    if @medical_case.save
      flash[:notice] = 'Erfolgreich erfasst.'
      respond_to do |format|
        format.html {
          redirect_to patient, :tab => 'medical_history'
          return
        }
        format.js {
          render :update do |page|
            page.insert_html :top, "treatment_#{@treatment.id}_medical_cases", :partial => 'medical_cases/item', :object => @medical_case
            page.remove "medical_case_form"
          end
        }
      end
    else
      render :action => 'new'
    end
  end

  # DELETE 
  def destroy
    @medical_case = MedicalCase.find(params[:id])
    @medical_case.destroy
    
    respond_to do |format|
      format.html { }
      format.js {
        render :update do |page|
          page.remove "medical_case_#{@medical_case.id}"
        end
      }
    end
  end
end
