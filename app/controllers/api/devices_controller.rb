# Api::DevicesController is the RESTful endpoint for managing device related
# settings. Consumed by the Angular SPA on the front end.
module Api
  class DevicesController < Api::AbstractController

    # GET /api/device
    def show
      current_device
        .if_null { create }
        .if_not_null { render json: current_device }
        # .if_null { render json: {error: "add device to account"}, status: 404 }
    end

    # POST /api/device
    def create
      mutate Devices::Create.run(device_params, user: current_user)
    end

    # PATCH/PUT /api/device
    def update
      # Because of the way bots are shared, there is no true 'update' action.
      # Just a creation/reasignment of bots based on UUID / Token.
      create
    end

    # DELETE /api/devices/1
    def destroy
      if current_device.users.include?(current_user)
        current_device.destroy
        render nothing: true, status: 204
      end
    end

    private

      # Only allow a trusted parameter "white list" through.
      def device_params
        { name:  params[:name]  || Haikunator.haikunate(99),
          uuid:  params[:uuid]  || SecureRandom.uuid,
          token: params[:token] || SecureRandom.hex }
      end
  end
end
