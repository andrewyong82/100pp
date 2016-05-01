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
          },
          webe: {
              name: "webe",
              link: "https://community.webe.com.my/projects/a+container+classroom+for+special+needs_p293",
              image: baselink + "webe.png",
              description: "Head on to www.webe.com.my to download the webe community app to support Cikgu Tan's Project. You can #makeithappen!"
          },
          piktochart: {
              name: "Piktochart",
              link: "https://piktochart.com",
              image: baselink + "piktochart.png",
              description: "Get rewarded with a FREE one month pro plan from Piktochart if you donate RM50 or more to a classroom project you believe in!"
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
        when self.id == 17
          partner = partners[:webe]
        when self.state == 'online'
          partner = partners[:piktochart]
        else
          return
      end

      return partner
    rescue OpenURI::HTTPError, TypeError => e
      Rails.logger.info "-----> #{e.inspect}"
    end
  end
end
