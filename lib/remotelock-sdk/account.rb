# frozen_string_literal: true

require_relative 'core/api'
require_relative 'api_mixins/user'

module RemoteLock
  # Manage and query RemoteLock accounts. '/account/serviceaccount' API paths in the RemoteLock::ServiceAccount .
  class Account < CoreApi
    include RemoteLock::Mixin::User

    # GET /api/v2/account/user/{id} : Retrieves a user by identifier (email address)
    # @param id [String] ID of the proxy
    # @return [RemoteLock::Response]
    def user_describe(id)
      wf_user_id?(id)
      api.get(['user', id].uri_concat)
    end

    # GET /api/v2/account/user : Get all user accounts
    # @param offset [Int] user account at which the list begins
    # @param limit [Int] the number of user accounts to return
    # @return [RemoteLock::Response]
    def user_list(offset = 0, limit = 100)
      api.get('user', offset: offset, limit: limit)
    end

    # GET /api/v2/account/{id}/businessFunctions : Return business functions of specific (user or service account).
    # @param id [String] user ID
    # @return [RemoteLock::Response]
    def business_functions(id)
      wf_account_id?(id)
      api.get([id, 'businessFunctions'].uri_concat)
    end

    # GET /api/v2/account : Get all accounts (users and service accounts) of a customer
    # @param offset [Int] account at which the list begins
    # @param limit [Int] the number of accounts to return
    # @return [RemoteLock::Response]
    def list(offset = 0, limit = 100)
      api.get('', offset: offset, limit: limit)
    end

    # GET /api/v2/account/{id} : Get a specific account (user or service account)
    # @param id [String] ID of the proxy
    # @return [RemoteLock::Response]
    def describe(id)
      wf_account_id?(id)
      api.get(id)
    end

    # POST /api/v2/account/{id}/addRoles : Add specific roles to the account (user or service account)
    # @param id [String] ID of the account
    # @param role_list [Array[String]] list of roles to add
    # @return [RemoteLock::Response]
    def add_roles(id, role_list)
      wf_account_id?(id)
      validate_role_list(role_list)
      api.post([id, 'addRoles'].uri_concat, role_list, 'application/json')
    end

    # POST /api/v2/account/{id}/addUserGroups : Adds specific user groups to the account (user or service account)
    # @param id [String] ID of the account
    # @param group_list [Array[String]] list of groups to add
    # @return [RemoteLock::Response]
    def add_user_groups(id, group_list)
      wf_account_id?(id)
      validate_usergroup_list(group_list)
      api.post([id, 'addUserGroups'].uri_concat, group_list, 'application/json')
    end

    # POST /api/v2/account/{id}/removeRoles : Removes specific roles from the account (user or service account)
    # @param id [String] ID of the account
    # @param role_list [Array[String]] list of roles to remove
    # @return [RemoteLock::Response]
    def remove_roles(id, role_list)
      wf_account_id?(id)
      validate_role_list(role_list)
      api.post([id, 'removeRoles'].uri_concat, role_list, 'application/json')
    end

    # POST /api/v2/account/{id}/removeUserGroups : Remove specific user groups from account (user or service account)
    # @param id [String] ID of the account
    # @param group_list [Array[String]] list of groups to remove
    # @return [RemoteLock::Response]
    def remove_user_groups(id, group_list)
      wf_account_id?(id)
      validate_usergroup_list(group_list)
      api.post([id, 'removeUserGroups'].uri_concat, group_list, 'application/json')
    end

    # POST /api/v2/account/{id}/grant/{permission} : Grant specific permission to (user or service account)
    # POST /api/v2/account/grant/{permission} : Grant specific permission to (users or service accounts)
    # @param id_list [Array[String],String] single account ID or list of account IDs
    # @param permission [String] permission group to grant to user.
    # @return [RemoteLock::Response]
    def grant(id, permission)
      id.is_a?(String) ? grant_to_id(id, permission) : grant_to_multiple(id, permission)
    end

    # POST /api/v2/account/{id}/revoke/{permission} : Revoke specific permission from (user or service account)
    # POST /api/v2/account/revoke/{permission} : Revoke specific permission from multiple (users or service accounts)
    # @param id [String,Array[String]] ID of the user, or list of user IDs
    # @param permission [String] permission group to revoke from user.
    # @return [RemoteLock::Response]
    def revoke(id, permission)
      id.is_a?(String) ? revoke_from_id(id, permission) : revoke_from_multiple(id, permission)
    end

    # POST /api/v2/account/deleteAccounts : Deletes multiple accounts (users or service accounts)
    # @param id [String] ID of the account
    # @param group_list [Array[String]] list of accounts to delete
    # @return [RemoteLock::Response]
    def delete_accounts(id_list)
      validate_account_list(id_list)
      api.post('deleteAccounts', id_list, 'application/json')
    end

    def user_create(body, send_email: false)
      raise ArgumentError unless body.is_a?(Hash)

      uri = send_email ? "?sendEmail=#{send_email}" : 'user'
      api.post(uri, body, 'application/json')
    end

    # POST /api/v2/account/user : Creates or updates a user account
    # @param id [String] a RemoteLock user ID
    # @param body [Hash] key-value hash of the parameters you wish to change
    # @param modify [true, false] if true, use {#describe()} to get a hash
    #   describing the existing object, and modify that with the new body. If false, pass the new body straight through.
    # @return [RemoteLock::Response]
    def user_update(body, modify: true)
      raise ArgumentError unless body.is_a?(Hash)

      return api.post('user', body, 'application/json') unless modify

      api.post('user', hash_for_update(describe(id).response, body), 'application/json')
    end

    # POST /api/v2/account/user/invite : Invite user accounts with given user groups and permissions.
    # @param body [Array[Hash]] array of hashes, each hash describing a user.
    #   See API docs for more details. It is your responsibility to validate the data which describes each user.
    # @return [RemoteLock::Response]
    def user_invite(body)
      raise ArgumentError unless body.is_a?(Array)
      raise ArgumentError unless body.first.is_a?(Hash)

      api.post('user/invite', body, 'application/json')
    end

    # POST /api/v2/account/validateAccounts : Return valid (users and service accounts) invalid identifiers from list
    # @param id_list [Array[String]] list of user IDs
    # @return [RemoteLock::Response]
    def validate_accounts(id_list)
      raise ArgumentError unless id_list.is_a?(Array)

      api.post('validateAccounts', id_list, 'application/json')
    end

    # DELETE /api/v2/account/{id} : Deletes an account (user or service account) identified by id
    # @param id [String] ID of the account
    # @return [RemoteLock::Response]
    def delete(id)
      wf_account_id?(id)
      api.delete(id)
    end

    private

    # @param id [String] ID of the user
    # @param permission [String] permission group to grant to user.
    # @return [RemoteLock::Response]
    def grant_to_id(id, permission)
      wf_account_id?(id)
      wf_permission?(permission)
      api.post([id, 'grant', permission].uri_concat)
    end

    # @param id_list [Array[String]] list of account IDs
    # @param permission [String] permission group to grant to user.
    # @return [RemoteLock::Response]
    def grant_to_multiple(id_list, permission)
      validate_account_list(id_list)
      wf_permission?(permission)
      api.post(['grant', permission].uri_concat, id_list, 'application/json')
    end

    # @param id [String] ID of the user
    # @param permission [String] permission group to revoke from user.
    # @return [RemoteLock::Response]
    def revoke_from_id(id, permission)
      wf_account_id?(id)
      wf_permission?(permission)
      api.post([id, 'revoke', permission].uri_concat)
    end

    # @param id_list [Array[String]] list of account IDs
    # @param permission [String] permission group to revoke from user.
    # @return [RemoteLock::Response]
    def revoke_from_multiple(id_list, permission)
      validate_account_list(id_list)
      wf_permission?(permission)
      api.post(['revoke', permission].uri_concat, id_list, 'application/json')
    end

    def update_keys
      %i[identifier groups userGroups roles ingestionPolicyId]
    end
  end
end
