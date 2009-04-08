require 'rubygems'
require 'sinatra'
require 'bio'

get '/' do
  @articles_count, @suggestions = suggestions(params[:q]) if params[:q]
  erb :index
end

helpers do
  def suggestions(keywords)
    pmids = Bio::PubMed.esearch(keywords + " AND medline[sb]")
    efetch = Bio::PubMed.efetch(pmids)
    medline = Bio::MEDLINE.new(efetch)
    count = {}
    medline.mesh.select {|m| m =~ /\*/}.each do |m|
      mh = m.sub(/\/.+$/, '').sub(/\*/, '')
      count[mh] ||= 0
      count[mh] += 1
    end
    return pmids.size, count.sort {|a, b| b[1] <=> a[1]}[0, 10]
  end
end
