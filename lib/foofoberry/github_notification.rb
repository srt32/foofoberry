require 'json'
require_relative 'client'

module FooFoBerry
  class GitHubNotification
    attr_reader :payload, :commit_id, :timestamp, :author_name, :author_email,
                :author_username, :repository_id, :repository_url, :client,
                :message

    def initialize(json_payload, input_client = FooFoBerry::Client.new)
      @client          = input_client
      @payload         = JSON.parse(json_payload)
      @commit_id       = @payload["head_commit"]["id"].to_s
      @timestamp       = @payload["head_commit"]["timestamp"]
      @author_name     = @payload["head_commit"]["author"]["name"]
      @author_email    = @payload["head_commit"]["author"]["email"]
      @message         = @payload["head_commit"]["message"]
      @author_username = @payload["head_commit"]["author"]["username"]
      @repository_id   = @payload["repository"]["id"].to_s
      @repository_url  = @payload["repository"]["url"].to_s.downcase
    end

    def save!
      response = client.post("commits", data.to_json)
      [response.status, JSON.parse(response.body)]
    end

    def data
      {
        :commit_id => commit_id,
        :timestamp => timestamp,
        :message   => message,
        :repository => {
          :id  => repository_id,
          :url => repository_url
        },
        :author => {
          :name     => author_name,
          :email    => author_email,
          :username => author_username
        }
      }
    end
  end
end
