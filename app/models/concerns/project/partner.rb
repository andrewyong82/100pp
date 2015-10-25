module Project::Partner
  extend ActiveSupport::Concern

  included do


    def partner

      baselink = "https://s3.amazonaws.com/100pp/assets/partners/"
      partners = {
          # affinbank: {
          #     name: "Affin Bank",
          #     image: baselink + "affinbank.gif",
          #     description: "Affinbank will be matching"
          # },
          kfit: {
              name: "KFit",
              link: "https://kfit.com",
              image: baselink + "kfit2.png",
              description: "As a token of appreciation, KFit will be giving out limited vouchers to thank some contributors of this project"
          },
          foodpanda: {
              name: "foodpanda",
              link: "https://foodpanda.my",
              image: baselink + "foodpanda.png",
              description: "As a token of appreciation, foodpanda will be giving out limited vouchers to thank some contributors of this project"
          }
      }

      partner = ''
      case
        when self.id == 6
          partner = partners[:kfit]
        when self.id == 1
          partner = partners[:kfit]
        when self.id == 8
          partner = partners[:foodpanda]
        else
          return
      end

      return partner
    rescue OpenURI::HTTPError, TypeError => e
      Rails.logger.info "-----> #{e.inspect}"
    end
  end
end
