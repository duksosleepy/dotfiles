#! /usr/bin/env python
# -*- coding: utf-8 -*-
# vim:fenc=utf-8
#
# Copyright © 2021 Pi-Yueh Chuang <pychuang@pm.me>
#
# Distributed under terms of the BSD 3-Clause license.

"""Functions used by an offlineimap instance.

Prerequisites:
    * google-auth: https://google-auth.readthedocs.io
    * google-auth-oauthlib: https://google-auth-oauthlib.readthedocs.io
"""
import pathlib
import pickle
import google.auth
import google_auth_oauthlib


def get_gmail_creds(account, client_credfile, scope=["https://mail.google.com/"]):
    """Get GMail account credential.

    Arguments
    ---------
    account : str
        Name of the account; used for naming the user credential file.
    client_credfile : str or pathlike
        Path to a JSON file that has client credentials. It can be created & downloaded from Google Cloud Console.

    Returns
    -------
    A `google.oauth2.credentials.Credentials` instance.
    """

    # process and save the absolute path of the credential file
    client_credfile = pathlib.Path(client_credfile).expanduser()

    if not client_credfile.is_absolute():
        client_credfile = pathlib.Path(__file__).parent.joinpath(client_credfile).expanduser()

    client_credfile = client_credfile.resolve()

    # token file contains pickled credentials of both the client and user-consented token
    user_credfile = pathlib.Path(__file__).expanduser().resolve().parent.joinpath(account+".cred")

    # try to see if the account's credential file exist; if so, read it
    if user_credfile.exists():
        with open(user_credfile, "rb") as fobj:
            user_creds = pickle.load(fobj)

        # return the credential object
        if user_creds.valid:
            return user_creds
    else:
        user_creds = None

    # user credentials exist but expired, just renew it if refresh token exists
    if user_creds and user_creds.expired and user_creds.refresh_token:
        user_creds.refresh(google.auth.transport.requests.Request())
        return user_creds

    # user credentials does not exist or does not have a refresh token; open the browser for consent
    flow = google_auth_oauthlib.flow.InstalledAppFlow.from_client_secrets_file(client_credfile, scope)
    user_creds = flow.run_local_server(port=59843)

    with open(user_credfile, "wb") as fobj:
        pickle.dump(user_creds, fobj)

    return user_creds


def get_gmail_client_id(account, client_credfile):
    """Get the client id (in bytes) from credentials."""
    creds = get_gmail_creds(account, client_credfile)
    return bytes(creds.client_id, "utf-8")  # return `bytes`
    # return creds.client_id  # return `str`


def get_gmail_client_secret(account, client_credfile):
    """Get the client secret (in bytes) from credentials."""
    creds = get_gmail_creds(account, client_credfile)
    return bytes(creds.client_secret, "utf-8")  # return `bytes`
    # return creds.client_secret  # return `str`


def get_gmail_token(account, client_credfile):
    """Get the token (in bytes) from credentials."""
    creds = get_gmail_creds(account, client_credfile)
    return bytes(creds.token, "utf-8")  # return `bytes`
    # return creds.token  # return `str`


def get_gmail_refresh_token(account, client_credfile):
    """Get the refresh token (in bytes) from credentials."""
    creds = get_gmail_creds(account, client_credfile)
    return bytes(creds.refresh_token, "utf-8")  # return `bytes`
    # return creds.refresh_token  # return `str`