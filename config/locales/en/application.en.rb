# frozen_string_literal: true

{
  en: {
    application: {
      name: ENV['APPLICATION_NAME'],
      title: 'VerifiedX - Trust and Credibility in the Digital Age',
      owner: 'Honeytree',
      description: 'VerifiedX is a platform that verifies individuals and organizations to provide trust' \
                   ' and credibility in the digital age. Join now and get verified.',
      keywords: 'verified user verified account real profile verified posts mastodon',
      support_email: ENV['SMTP_DEFAULT_FROM'],
      key: 'verified_x'
    },
    'webhooks/outgoing/endpoints': {

      fields:
        { api_version:
            { options:
                { '1': '' } } }
      # 🚅 super scaffolding will insert new api versions above this line.}
    }
  }
}