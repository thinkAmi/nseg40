NSEG40
========

NSEG #40 で発表した際のデモアプリです。




開発環境
----------

* OS: Ubuntu 12.04 LTS
* Ruby 1.9.3
* Heroku


セットアップ
----------

1. TwilioにTrialアカウントを作り、電話番号認証やURL設定を行います。


2. Herokuにアプリを作ります。  

        heroku create <app_name>


3. Herokuに環境変数を追加します。

        heroku config:set TWILIO_SID=<TwilioのSID>
        heroku config:set TWILIO_TOKEN=<TwilioのToken>
        heroku config:set TWILIO_PHONE_NUMBER=<Twilioからもらった電話番号>
        heroku config:set TWILIO_VALIDATED_PHONE_NUMBER=<認証した自分の電話番号>


4. Herokuで「Redis To Go」アドオンを入れます。

        heroku addons:add redistogo:nano


5. Gitリポジトリを作って、Herokuへpushします。

        git init
        git add .
        git commit -m 'hogehoge'
        git push heroku master



ライセンス
----------
* Twilio関連ライブラリはそれらのライセンスに従います。
* CeVIOの音声(wavファイル)は、そのライセンスに従います。
* その他は、[NYSL](http://www.kmonos.net/nysl/)です。
