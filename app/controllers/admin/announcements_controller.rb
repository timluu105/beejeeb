class Admin::AnnouncementsController < Admin::ApplicationController
  before_action :set_announcement, only: %i[edit update destroy]

  def index
    # @todo fix pagination for datatable at UI
    @announcements = Announcement.page(params[:page]).per(100)
  end

  def new
    @announcement = Announcement.new
  end

  def create
    @announcement = Announcement.create announcement_params

    if @announcement.save
      redirect_to %i[admin announcements], notice: 'Announcement succesfuly created'
    else
      flash.now[:error] = 'Announcement is not created'
      render :new
    end
  end

  def edit
  end

  def update
    if @announcement.update announcement_params
      redirect_to %i[admin announcements], notice: 'Announcement succesfuly updated'
    else
      flash.now[:error] = 'Announcement is not updated'
      render :edit
    end
  end

  def destroy
    @announcement.destroy
    redirect_to %i[admin announcements], notice: 'Announcement succesfully deleted'
  end

  protected

  def announcement_params
    params.require(:announcement).permit!
  end

  def set_announcement
    @announcement = Announcement.find params[:id]
  end
end
