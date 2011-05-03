class OutputElementNode < ViewNode
  validate :parent_is_slide

  validates :element_id, :presence => true
  validates :element_type, :inclusion => %w[OutputElement]
end

# == Schema Information
#
# Table name: view_nodes
#
#  id             :integer(4)      not null, primary key
#  key            :string(255)
#  element_id     :integer(4)
#  element_type   :string(255)
#  ancestry       :string(255)
#  position       :integer(4)
#  ancestry_depth :integer(4)      default(0)
#  type           :string(255)
#
