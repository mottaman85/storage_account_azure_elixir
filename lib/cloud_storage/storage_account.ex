defmodule AzureService.StorageAccount do
  @moduledoc """
  Documentation for Azure Storage Account.
  """

  @base_login Application.get_env(:storage_account_azure, :azure_default_base_login)
  @base_blob_url Application.get_env(:storage_account_azure, :azure_default_base_blob)
  @tenant_id Application.get_env(:storage_account_azure, :azure_tenant)
  @client_id Application.get_env(:storage_account_azure, :azure_default_client)
  @client_secret Application.get_env(:storage_account_azure, :azure_default_client_secret)
  @base_resource Application.get_env(:storage_account_azure, :azure_default_base_resource)
  @container Application.get_env(:storage_account_azure, :azure_container_storage_account)
  @storage_account Application.get_env(:storage_account_azure, :azure_storage_account)
  @sas_token Application.get_env(:storage_account_azure, :sas_token)
  @options [timeout: 600_000, recv_timeout: 600_000]
  @doc """
  ## Examples
  iex> AzureService.StorageAccount.get_from_url("https://www.google.com.br/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png", "nomathers")
  {:ok, ""}

  iex> AzureService.StorageAccount.get_from_url("https://www.google.com.br/imagasdadsaes/branding/googlelogo/2x/googlelogo_color_272x92dp.png", "nomathers")
  {:error, 404}

  """
  def get_from_url(url, remote_path, _bucket \\ nil) do
    options = [
      hackney: [:insecure]
    ]

    {:ok, response} = HTTPoison.get(url, [], options)

    case response.status_code do
      200 ->
        content = response.body

        type =
          response.headers
          |> List.keyfind("Content-Type", 0)
          |> elem(1)

        {:ok, ""}

      _ ->
        {:error, response.status_code}
    end
  end

  @doc """
    Upload a file
    
    ## Examples

    iex> AzureService.StorageAccount.upload("test/60_daysnopantsdddd.png", "clapimage/60_daysnopantsdddd.png")
    {:ok, "clapimage/60_daysnopantsdddd.png"}

  """
  def upload(local_path, remote_path) do
    {:ok, file_content} = File.read(local_path)
    file_type = MIME.from_path(remote_path)
    put(remote_path, file_content, file_type)
  end

  def put(full_path, content \\ "", type \\ "application/octet-stream") do
    header = [
      "Content-Type": type,
      "Content-Length": 0,
      "x-ms-blob-type": "BlockBlob"
    ]

    url =
      full_path
      |> storage_account_url

    IO.puts(url)
    {:ok, response} = HTTPoison.put(url, content, header, @options)

    case response.status_code do
      201 ->
        {:ok, url}

      _ ->
        IO.puts(response)
        {:error, response.status_code}
    end
  end

  defp storage_account_url(abs_path) do
    "https://#{@base_schema}"
    |> Kernel.<>("#{@storage_account}")
    |> Kernel.<>("#{@base_blob_url}")
    |> Kernel.<>("#{@container}")
    |> Kernel.<>("/")
    |> Kernel.<>(abs_path)
    |> Kernel.<>("?")
    |> Kernel.<>("#{@sas_token}")
  end

  @doc """
  Get a REST Token for SA

  ## Example
    iex> AzureService.StorageAccount.get_token() |> is_nil()
    false

  """

  def get_token() do
    headers = [
      "Content-Type": "application/x-www-form-urlencoded"
    ]

    post_url = "/oauth2/token"

    url =
      "#{@base_login}"
      |> Kernel.<>("#{@tenant_id}")
      |> Kernel.<>(post_url)

    body =
      "grant_type=client_credentials&client_id="
      |> Kernel.<>("#{@client_id}")
      |> Kernel.<>("&client_secret=")
      |> Kernel.<>("#{@client_secret}")
      |> Kernel.<>("&resource=")
      |> Kernel.<>("#{@base_resource}")

    case HTTPoison.post(url, body, headers) do
      {:ok, response} ->
        response.body
        |> Jason.decode!()
        |> Map.get("access_token")

      _ ->
        {:error}
    end
  end
end
