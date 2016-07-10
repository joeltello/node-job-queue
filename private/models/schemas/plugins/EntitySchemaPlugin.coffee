module.exports = (EntitySchema) ->
  # Represents an abstract entity
  EntitySchema.add
    created_at:
      type: Date
      default: Date.now
      index: yes
    updated_at:
      type: Date
      index: yes
    deleted_at:
      type: Date
      index: yes

  # Async version of pre-save. Must call done()
  EntitySchema.pre 'save', yes, (next, done)->
    next()
    @updated_at = Date.now()
    done()