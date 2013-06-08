# -*- coding: utf-8 -*-
require 'twilio-ruby'
require 'redis'


redis_uri = URI.parse(ENV['REDISTOGO_URL'])
# Sinatraのスコープが異なる場所で参照されているため、ここでは定数としておく
REDIS = Redis.new(host: redis_uri.host, port: redis_uri.port, password: redis_uri.password)
# Sinatraのスコープが同じ場所で参照されているため、変数にしておく
client = Twilio::REST::Client.new(ENV['TWILIO_SID'], ENV['TWILIO_TOKEN'])



get '/' do
  # 静的ファイルを表示させたかったため、やってみた
  send_file File.join(settings.public_folder, 'index.html')
end


post '/memorize' do
  REDIS.set('twilio_message', params['message'])

  @well = '記憶しました'
  erb :memorize
end


post '/menu' do
  Twilio::TwiML::Response.new do |r|
    r.Gather(action: '/selection', method: 'POST', numDigits: 1 ) do |g|
      g.Say('再生は1を、録音は2を押してください', language: 'ja-jp')
    end
  end.text
end


post '/selection' do
  case params[:Digits]
  when '1'
    read_text

  when '2'
    Twilio::TwiML::Response.new do |r|
      r.Say('10秒で　ふきこんでください。おわりは　イゲタ', language: 'ja-jp')
      r.Record(action: '/repeat', method: 'POST', maxLength: 10, finishOnKey: '#')
    end.text

  else
    Twilio::TwiML::Response.new do |r|
      r.Say('Cannot use this button', voice: 'man')
    end.text

  end
end


post '/repeat' do
  Twilio::TwiML::Response.new do |r|
    r.Say('再生します', language: 'ja-jp')
    r.Play(params['RecordingUrl'])
  end.text
end


get '/list' do
  @recordings = client.account.recordings.list
  @delete_url = uri('/delete?sid=')
  @well = '録音一覧'
  erb :recordings
end


get '/delete' do
  recording = client.account.recordings.get(params['sid'])
  recording.delete

  @well = '削除しました'
  erb :delete
end


post '/call' do
  client.account.calls.create(
    from: ENV['TWILIO_PHONE_NUMBER'],
    to: ENV['TWILIO_VALIDATED_PHONE_NUMBER'],
    url: uri('/read')
  )

  @well = '携帯電話へ発信'
  erb :call
end


post '/read' do
  read_text
end


post '/cevio' do
  client.account.calls.create(
    from: ENV['TWILIO_PHONE_NUMBER'],
    to: ENV['TWILIO_VALIDATED_PHONE_NUMBER'],
    url: uri('/voice')
  )

  @well = 'Cevioの声で発信'
  erb :cevio
end


post '/voice' do
  Twilio::TwiML::Response.new do |r|
    r.Say('トゥイリオの、おんせい。', language: 'ja-jp')
    r.Say('エヌセグ、40回、開催おめでとう。', language: 'ja-jp')
    r.Say('チェビオの、おんせい。', language: 'ja-jp')
    r.Play(uri('/wav'))
  end.text
end

get '/wav' do
  content_type 'audio/wav'
  send_file File.join(settings.public_folder, 'voice.wav')
end



def read_text
  message = REDIS.get('twilio_message')

  Twilio::TwiML::Response.new do |r|
    r.Say message, language: 'ja-jp'
  end.text
end


helpers do
  def make_time(rfc2822_time)
    utc = Time.rfc2822(rfc2822_time)
    local = utc + 60 * 60 * 9
    local.strftime('%Y/%m/%d %T')
  end
end
