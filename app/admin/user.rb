ActiveAdmin.register User do

  # Role Checking
  actions :all
  controller do

    def action_methods
      if current_user.role == 'admin'
        super
      elsif current_user.role == 'publisher'
        super - ['new', 'create', 'destroy']
      elsif current_user.role == 'editor'
        super - ['destroy']
      end
    end

  end

  permit_params :name, :email, :role, :suspended, :password, :password_confirmation

  menu priority: 6

  index :download_links => false do
    selectable_column
    #id_column
    column "Photo", :image do |user|
      user.image ? image_tag(user.image) : ''
    end
    column :name
    column :email
    column "Provider" do |user|
      if user.provider
        link_to user.provider.capitalize, "https://fb.com/" + user.uid, target: "_blank", rel: "nofollow"
      end
    end
    column :role
    column "Suspended", :suspended
    #column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end

  filter :name_contains, label: 'Name Search'
  filter :created_at

  form do |f|
    f.inputs "User Details" do
      f.input :name
      f.input :email
      f.input :suspended, label: "Suspended"
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

end
