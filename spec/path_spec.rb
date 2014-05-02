require 'spec_helper'

describe "when testing path helpers" do
  it "should define Libyajl2::VENDORED_LIBYAJL2_DIR" do
    expect(Libyajl2::VENDORED_LIBYAJL2_DIR).to include("lib/libyajl2/vendored-libyajl2")
  end

  it "should define Libyajl2.opt_path" do
    expect(Libyajl2.opt_path).to include("lib/libyajl2/vendored-libyajl2/lib")
  end

  it "should define Libyajl2.include_path" do
    expect(Libyajl2.include_path).to include("lib/libyajl2/vendored-libyajl2/include")
  end
end
