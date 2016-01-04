class Certifier < ActiveRecord::Base

  belongs_to :environment

  has_many :qualifier_certifiers, :dependent => :destroy
  has_many :qualifiers, :through => :qualifier_certifiers

  has_many :product_qualifiers
  has_many :products, :through => :product_qualifiers, :source => :product

  validates_presence_of :environment_id
  validates_presence_of :name

  def destroy
    product_qualifiers.each { |pq| pq.update_attributes! :certifier => nil }
    super
  end

  def link
    self[:link] || ''
  end

  def <=>(b)
    self.name.downcase.transliterate <=> b.name.downcase.transliterate
  end

  after_save_reindex [:products], :with => :delayed_job

end
