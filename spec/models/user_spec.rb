require 'spec_helper'

describe User do
  it "orders by name" do
    lindeman = User.create!(name: "Lindeman", email: "foo@example.com", password: "secret13")
    chelimsky = User.create!(name: "Chelimsky", email: "foo2@example.com", password: "secret13")

    expect(User.order("name ASC")).to eq([chelimsky, lindeman])
  end
end