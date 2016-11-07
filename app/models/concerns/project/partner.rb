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
          },
          repsol: {
              name: "Repsol",
              link: "https://www.repsol.com",
              image: baselink + "repsol.png",
              description: "This project was fully realised by the team at Repsol!"
          },
          ytl: {
              name: "YTL Foundation",
              link: "https://www.frogclassroom.com",
              image: baselink + "ytlf2.png",
              description: "All successful campaigns will unlock RM15,000 worth of furniture and fittings to complete the Frog Classroom transformation!"
          },
          slb: {
              name: "Schlumberger",
              link: "https://www.slb.com",
              image: baselink + "schlumberger.png",
              description: "This project has been adopted by Schlumberger!"
          },
          nbs: {
              name: "Nation Building School",
              link: "http://nationbuildingschool.com",
              image: baselink + "nbs.jpg",
              description: "This project has been adopted by Nation Building School!"
          },
          biggive: {
              name: "The BIG GIVE",
              link: "http://biggive.100percentproject.org",
              image: baselink + "biggive.png",
              description: "Join Malaysia's BIGGEST giving campaign aimed at helping teachers and students start their school year with a dose of inspiration!"
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
        when self.id == 54
          partner = partners[:repsol]
        when self.id == 51
          partner = partners[:slb]
        when self.id == 72
          partner = partners[:nbs]
        when self.category_id == 11
          partner = partners[:ytl]
        when self.category_id == 13
          partner = partners[:biggive]
        when self.state == ('online')
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
