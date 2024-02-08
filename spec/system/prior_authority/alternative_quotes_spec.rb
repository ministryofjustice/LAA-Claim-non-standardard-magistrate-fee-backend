require 'system_helper'

RSpec.describe 'Prior authority applications - alternative quote' do
  context 'when I visit the quote summary screen' do
    before do
      fill_in_until_step(:primary_quote_summary)
      click_on 'Save and continue'
      click_on 'Alternative quotes'
    end

    it 'lets me add no quotes' do
      choose 'No'
      fill_in 'Why did you not get other quotes?', with: 'Some reason'
      click_on 'Save and continue'
      expect(page).to have_content 'Alternative quotesCompleted'
    end

    it 'validates appropriately' do
      choose 'No'
      click_on 'Save and continue'
      expect(page).to have_content 'Explain why you did not get other quotes'
    end

    context 'when I click through to add alternative quotes' do
      before do
        choose 'Yes'
        click_on 'Save and continue'
      end

      it 'allows me to add an alternative quote' do
        fill_in 'Contact full name', with: 'Mrs Expert'
        fill_in 'Organisation', with: 'ExpertiseCo'
        fill_in 'Postcode', with: 'SW1 1AA'
        click_on 'Save and continue'

        expect(page).to have_content "You've added 1 alternative quote"
        expect(page).to have_content 'Mrs Expert'
      end

      it 'validates' do
        click_on 'Save and continue'
        expect(page).to have_content "Enter the contact's full name"
      end

      context 'When I have added a quote' do
        before do
          fill_in 'Contact full name', with: 'Mrs Expert'
          fill_in 'Organisation', with: 'ExpertiseCo'
          fill_in 'Postcode', with: 'SW1 1AA'
          click_on 'Save and continue'
        end

        it 'allows me to edit a quote' do
          click_on 'Change'

          fill_in 'Contact full name', with: 'Mr Expert'
          click_on 'Save and continue'

          expect(page).to have_content "You've added 1 alternative quote"
          expect(page).to have_content 'Mr Expert'
        end

        it 'allows me to move on' do
          choose 'No'
          click_on 'Save and continue'

          expect(page).to have_content 'Alternative quotesCompleted'
        end

        it 'allows me to remove a quote' do
          click_on 'Delete'
          expect(page).to have_content 'Are you sure you want to delete this alternative quote?'
          click_on 'Yes, delete it'
          expect(page).to have_content 'The alternative quote was deleted'
          expect(page).to have_content 'Have you got other quotes?'
        end

        it 'allows me to cancel deletion' do
          click_on 'Delete'
          click_on 'No, do not delete it'
          expect(page).to have_content "You've added 1 alternative quote"
        end
      end
    end
  end
end
