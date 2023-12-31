# frozen_string_literal: true

module RemoteLock
  module Mixin
    #
    # ACL mixins
    #
    # Mix this module into class which supports ACLs, ensuring there is a
    # valid_id? method to perform ID validation.
    #
    module Acl
      # GET /api/v2/{entity}/acl
      # Get list of Access Control Lists for the specified object
      # @param id_list [Array[String]] array of object IDs
      # @return [RemoteLock::Response]
      #
      def acls(id_list)
        id_list.each { |id| valid_id?(id) }
        api.get_flat_params('acl', id: id_list)
      end

      # POST /api/v2/{entity}/acl/add
      # Adds the specified ids to the given object's ACL
      # @param id [String] ID of object
      # @param view [Array[String]] array of entities allowed to view
      #   the object. Entities may be users or groups
      # @param modify [Array[String]] array of entities allowed to
      #   view and modify the object. Same rules as @view.
      # @return [RemoteLock::Response]
      #
      def acl_add(id, view = [], modify = [])
        valid_id?(id)

        api.post(%w[acl add].uri_concat,
                 acl_body(id, view, modify),
                 'application/json')
      end

      # POST /api/v2/{entity}/acl/remove
      # Removes the specified ids from the given object's ACL
      #
      # Though the API method is 'remove', the acl method names have
      # been chosen to correspond with the tag methods.
      # @param id [String] ID of object
      # @param view [Array[String]] array of entities allowed to view
      #   the object. Entities may be users or groups
      # @param modify [Array[String]] array of entities allowed to
      #   view and modify the object. Same rules as @view.
      # @return [RemoteLock::Response]
      #
      def acl_delete(id, view = [], modify = [])
        valid_id?(id)

        api.post(%w[acl remove].uri_concat,
                 acl_body(id, view, modify),
                 'application/json')
      end

      # PUT /api/v2/{entity}/acl/set
      # Set ACL for the specified object
      # @param id [String] ID of object
      # @param view [Array[String]] array of entities allowed to view
      #   the object. Entities may be users or groups
      # @param modify [Array[String]] array of entities allowed to
      #   view and modify the object. Same rules as @view.
      # @return [RemoteLock::Response]
      #
      def acl_set(id, view = [], modify = [])
        api.put(%w[acl set].uri_concat, acl_body(id, view, modify))
      end

      private

      def acl_body(id, view, modify)
        valid_id?(id)
        valid_acl_body?(view)
        valid_acl_body?(modify)

        [{ entityId: id, viewAcl: view, modifyAcl: modify }]
      end

      def valid_acl_body?(list)
        return true if list.is_a?(Array) && list.all?(String)

        raise ArgumentError
      end
    end
  end
end
