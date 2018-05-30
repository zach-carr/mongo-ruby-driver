require 'spec_helper'

describe Mongo::Error::Parser do

  describe '#message' do

    let(:parser) do
      described_class.new(document)
    end

    context 'when the document contains no error message' do

      let(:document) do
        { 'ok' => 1 }
      end

      it 'returns an empty string' do
        expect(parser.message).to be_empty
      end
    end

    context 'when the document contains an errmsg' do

      let(:document) do
        { 'errmsg' => 'no such command: notacommand', 'code'=>59 }
      end

      it 'returns the message' do
        expect(parser.message).to eq('no such command: notacommand (59)')
      end
    end

    context 'when the document contains writeErrors' do

      context 'when only a single error exists' do

        let(:document) do
          { 'writeErrors' => [{ 'code' => 9, 'errmsg' => 'Unknown modifier: $st' }]}
        end

        it 'returns the message' do
          expect(parser.message).to eq('Unknown modifier: $st (9)')
        end
      end

      context 'when multiple errors exist' do

        let(:document) do
          {
            'writeErrors' => [
              { 'code' => 9, 'errmsg' => 'Unknown modifier: $st' },
              { 'code' => 9, 'errmsg' => 'Unknown modifier: $bl' }
            ]
          }
        end

        it 'returns the messages concatenated' do
          expect(parser.message).to eq(
            'Unknown modifier: $st (9), Unknown modifier: $bl (9)'
          )
        end
      end
    end

    context 'when the document contains $err' do

      let(:document) do
        { '$err' => 'not authorized for query', 'code' => 13 }
      end

      it 'returns the message' do
        expect(parser.message).to eq('not authorized for query (13)')
      end
    end

    context 'when the document contains err' do

      let(:document) do
        { 'err' => 'not authorized for query', 'code' => 13 }
      end

      it 'returns the message' do
        expect(parser.message).to eq('not authorized for query (13)')
      end
    end

    context 'when the document contains a writeConcernError' do

      let(:document) do
        { 'writeConcernError' => { 'code' => 100, 'errmsg' => 'Not enough data-bearing nodes' } }
      end

      it 'returns the message' do
        expect(parser.message).to eq('Not enough data-bearing nodes (100)')
      end
    end
  end
  
  describe '#code' do
    let(:parser) do
      described_class.new(document)
    end

    context 'when document contains code' do
      let(:document) do
        { 'ok' => 0, 'errmsg' => 'not master', 'code' => 10107, 'codeName' => 'NotMaster' }
      end
      
      it 'returns the code' do
        expect(parser.code).to eq(10107)
      end
    end

    context 'when document does not contain code' do
      let(:document) do
        { 'ok' => 0, 'errmsg' => 'not master' }
      end
      
      it 'returns nil' do
        expect(parser.code).to eq(nil)
      end
    end
  end
  
  describe '#code_name' do
    let(:parser) do
      described_class.new(document)
    end

    context 'when document contains code name' do
      let(:document) do
        { 'ok' => 0, 'errmsg' => 'not master', 'code' => 10107, 'codeName' => 'NotMaster' }
      end
      
      it 'returns the code name' do
        expect(parser.code_name).to eq('NotMaster')
      end
    end

    context 'when document does not contain code name' do
      let(:document) do
        { 'ok' => 0, 'errmsg' => 'not master' }
      end
      
      it 'returns nil' do
        expect(parser.code_name).to eq(nil)
      end
    end
  end
end
