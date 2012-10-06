require 'spec_helper'

describe 'Deleting a DOM element'do
  it 'deletes it', :js => true  do
    visit "/"
    click_on 'Delete the element'
    page.should_not have_css(".element_to_delete", text: "This stuff will be gone!")
  end
end
