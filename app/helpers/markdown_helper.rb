module MarkdownHelper
  def markdown(text)
    unless @markdown
      render_options = {
        hard_wrap: true,
        space_after_headers: true,
        link_attributes: { target: '_blank' },
        fenced_code_blocks: true,
        lax_html_blocks: true,
        strikethrough: true,
        with_toc_data: true
      }
      extensions = {
        no_intra_emphasis: true,
        fenced_code_blocks: true,
        disable_indented_code_blocks: true,
        autolink: true,
        tables: true,
        underline: true,
        highlight: true
      }
      renderer = Redcarpet::Render::HTML.new(render_options)
      @markdown = Redcarpet::Markdown.new(renderer, extensions)
    end

    @markdown.render(text)
  end
end
