atom_feed :language => 'en-US' do |feed|
  feed.title "Shelr.tv - new activity for #{@user.nickname}"
  feed.updated @comments.last.updated_at

  @comments.each do |comment|
    feed.entry(comment) do |entry|
      entry.url comment_url(comment)
      entry.title "Comment from #{comment.user.nickname} for \"#{comment.commentable.title}\""
      entry.content comment.body, :type => 'html'

      # the strftime is needed to work with Google Reader.
      entry.updated(comment.updated_at.strftime("%Y-%m-%dT%H:%M:%SZ"))

      entry.author do |author|
        author.name comment.user.nickname
        author.url user_url(comment.user)
      end
    end
  end
end
