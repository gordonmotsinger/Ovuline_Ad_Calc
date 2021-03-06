class QuotesController < ApplicationController
  before_action :set_quote, only: [:show, :edit, :update, :destroy]

  def index
    @quotes = Quote.all

  end

  def show
    @quotes = Quote.find(params[:company_id])
  end

  def new
    if session[:current_company_id] == nil
      redirect_to root_path
      flash[:notice] = 'You must fill out information about your company before continuing'
    end
    @quotes = Quote.all
    @quote = Quote.new
  end

  def edit
    @quote = Quote.find(params[:id])
    @company = @quote.company_id
  end

  def create
    @quote = Quote.new(quote_params)
    @quote.company_id = session[:current_company_id]
    @company = Company.find(session[:current_company_id])
    #session[:company_name] = @company.companyname
    if @quote.save
      flash[:notice] = 'Your quote information has been added'
      send_notification
      redirect_to thankyou_path
    else
      render action: 'new'
     end
  end

  def update
    @quote = Quote.find(params[:id])
    if @quote.update_attributes(quote_params)
      flash[:notice] = 'Your quote was updated'
      @company = @quote.company_id
      redirect_to company_path
    else
      render action: 'new'
    end
  end

  def destroy
    @quote.destroy
    @company = Company.find(session[:employee_company_id])
    respond_to do |format|
      format.html { redirect_to company_path, notice: 'Line-item was successfully removed.' }
    end
  end

  def thankyou
  end

  #Need to consider moving this method to a seperate helper method location and giving it a message for :text based on where the request comes from (e.g. Companies Controller or Quotes Controller). Keeping here for the time being because this is possibly the only use for notifications
  def send_notification
      @emails = EmployeeEmail.all
      if @emails == []
        return
      else
      #rather unwise to have my api key just sitting here in the code, need to check if a new api-key can be generated
      RestClient.post "https://api:key-5f4ada711a8a86a1292bcfe23aa9d0aa"\
      "@api.mailgun.net/v2/sandbox3fcc0ad1e9ee457da78753f228405f7e.mailgun.org/messages",
      :from => "Ovuline Advertising Notification System <mailgun@sandbox3fcc0ad1e9ee457da78753f228405f7e.mailgun.org>",
      :to => send_who_us,
      :subject => "Ovuline Advertising Site - A New Lead!",
      #ack! I need to find a way to get @company info into this next line
      :text => "This is the Ovuline Advertising Notification System test message! #{@company.companyname} company has submitted information for your inspection. View it at https://advertising-platform.herokuapp.com/employees"
      end
  end
    
  def send_who_us
    @emails = EmployeeEmail.all
    @who_array = []
    @emails.each do |f|
        @who_array << f.email
    end
    @who=""
    @who_array.each do |f|
        @who << "#{f}"
        #need to break this down to test it piece by piece
        if f != @who_array[-1]
            @who << ", "
        end
    end
    #this method finishes with this return instead of an end, could cause trouble if @who is ever incorrect
    return @who


end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_quote
      @quote = Quote.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def quote_params
      params[:quote].permit(:id, :ad_type, :app_type, :mobile_platform, :budget, :company_id, :native_ad, :social_ad, :email_campaign, :ovuline_exclusive, :target_ttc, :target_preg, :target_sig_other, :target_1st_trim, :target_2nd_trim, :target_3rd_trim, :begin_date, :end_date)
    end
end
