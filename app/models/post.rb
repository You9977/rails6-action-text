class Post < ApplicationRecord
  has_rich_text :content

  validates :title, length: { maximum: 32 }, presence: true
  validate  :validate_content_length
  validate  :validate_content_attachable_byte_size
  validate  :validate_content_attachable_count

  MAX_CONTENT_LENGTH = 50
  ONE_KILOBYTE = 1024
  MEGA_BYTES = 3
  MAX_CONTENT_ATTACHMENT_BYTE_SIZE = MEGA_BYTES* 1000 * ONE_KILOBYTE
  MAX_CONTENT_ATTACHMENT_COUNT = 4

  private

    def validate_content_length
      length = content.to_plain_text.length

      if length > MAX_CONTENT_LENGTH
        errors.add(
          :content,
          :too_long,
          max_content_length: MAX_CONTENT_LENGTH,
          length: length
        )
      end
    end

    def validate_content_attachable_byte_size
      byte_size = content.body.attachables.grep(ActiveStorage::Blob).each do |attachable|

        if attachable.byte_size > MAX_CONTENT_ATTACHMENT_BYTE_SIZE
          errors.add(
            :base,
            :content_attachment_byte_size_is_too_big,
            max_byte_size: MEGA_BYTES,
            byte_size: attachable.byte_size,
            max_byte: MAX_CONTENT_ATTACHMENT_BYTE_SIZE
          )
        end
      end
    end

    def validate_content_attachable_count
      content_file = content.body.attachables.grep(ActiveStorage::Blob)
        
        if content_file.count > MAX_CONTENT_ATTACHMENT_COUNT
          errors.add(
            :base,
            :content_attachment_count_is_too_many,
            max_attachment_count: MAX_CONTENT_ATTACHMENT_COUNT            
          )
        end
      
    end
end
