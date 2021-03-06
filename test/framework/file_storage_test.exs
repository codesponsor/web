defmodule Framework.FileStorageTest do
  use ExUnit.Case

  describe "store/1" do
    test "it stores the asset in s3 and returns {:ok, filename, bucket} for saving" do
      {:ok, filename, bucket, height, width} =
        %Plug.Upload{
          content_type: "image/jpeg",
          path: Path.expand("../../test/support/mock.jpg", __DIR__),
          filename: "mock.jpg"
        }
        |> Framework.FileStorage.store()

      assert filename =~ "mock.jpg"
      assert bucket == "stub"
      assert height == 215
      assert width == 215
    end

    test "it returns {:error, :invalid_file_type} if the file isn't a jpg, png or gif" do
      assert %Plug.Upload{
               content_type: "image/pdf",
               path: Path.expand("../../test/support/mock.pdf", __DIR__),
               filename: "mock.pdf"
             }
             |> Framework.FileStorage.store() == {:error, :invalid_file_type}
    end
  end

  describe "url/3" do
    test "it returns the signed s3 url for the asset" do
      [cdn_host: cdn_host] = Application.get_env(:code_fund, Framework.FileStorage)

      assert Framework.FileStorage.url("stub.jpg") == "https://#{cdn_host}/stub.jpg"
    end

    test "it returns nil if object is nil" do
      refute Framework.FileStorage.url(nil)
    end
  end
end
