load("@stdlib//jcrypto", _JCrypto="jcrypto")
load("@stdlib//binascii", hexlify="hexlify")
load("@stdlib//codecs", codecs="codecs")
load("@stdlib//larky", larky="larky")
# load("@vendor//option/result", Error="Error")

def Keccak_Hash(data=None, digest_bytes=256, update_after_digest=False):
    """
    A Keccak hash object.
        Do not instantiate directly.
        Use the :func:`new` function.

        :ivar digest_size: the size in bytes of the resulting hash
        :vartype digest_size: integer
    
    """

    def __init__(data, digest_bytes, update_after_digest):
        """
         The size of the resulting hash in bytes.

        """
        self_ = {'digest_size': digest_bytes, '_update_after_digest': update_after_digest, '_digest_done': False}
        self_['_state'] = _JCrypto.Hash.Keccak_256(data)
        # if data:
        #     self_['_state'].update(data)
        return larky.mutablestruct(**self_)
    self = __init__(data, digest_bytes, update_after_digest)

    # def update(data):
    #     """
    #     Continue hashing of a message by consuming the next chunk of data.

    #             Args:
    #                 data (byte string/byte array/memoryview): The next chunk of the message being hashed.
        
    #     """

    #     if self._digest_done and not self._update_after_digest:
    #         fail('TypeError("You can only call \'digest\' or \'hexdigest\' on this object")')


    #     if data == None:
    #         fail("TypeError: object supporting the buffer API required")
    #     self._state.update(data)
    # self.update = update

    def digest():
        """
        Return the **binary** (non-printable) digest of the message that has been hashed so far.

                :return: The hash digest, computed over the data processed so far.
                         Binary form.
                :rtype: byte string
        
        """
        self._digest_done = True
        return self._state.digest()
    self.digest = digest

    def hexdigest():
        """
        Return the **printable** digest of the message that has been hashed so far.

                :return: The hash digest, computed over the data processed so far.
                         Hexadecimal encoded.
                :rtype: string
        
        """
        return codecs.decode(hexlify(self._state), encoding='utf-8')
    self.hexdigest = hexdigest

    def new(**kwargs):
        """
        Create a fresh Keccak hash object.
        """
        if "digest_bytes" not in kwargs and "digest_bits" not in kwargs:
            kwargs["digest_bytes"] = self.digest_size

        return Keccak_Hash(**kwargs)
    self.new = new
    return self

def new(**kwargs):
    """
    Create a new hash object.

        Args:
            data (bytes/bytearray/memoryview):
                The very first chunk of the message to hash.
                It is equivalent to an early call to :meth:`Keccak_Hash.update`.
            digest_bytes (integer):
                The size of the digest, in bytes (28, 32, 48, 64).
            digest_bits (integer):
                The size of the digest, in bits (224, 256, 384, 512).
            update_after_digest (boolean):
                Whether :meth:`Keccak.digest` can be followed by another
                :meth:`Keccak.update` (default: ``False``).

        :Return: A :class:`Keccak_Hash` hash object
    
    """

    data = kwargs.pop("data", None)
    update_after_digest = kwargs.pop("update_after_digest", False)

    digest_bytes = kwargs.pop("digest_bytes", None)
    digest_bits = kwargs.pop("digest_bits", None)
    if None not in (digest_bytes, digest_bits):
        fail("TypeError: Only one digest parameter must be provided")
    if (None, None) == (digest_bytes, digest_bits):
        fail("TypeError: Digest size (bits, bytes) not provided")
    if digest_bytes != None:
        if digest_bytes not in (28, 32, 48, 64):
            fail("ValueError: 'digest_bytes' must be: 28, 32, 48 or 64")
    else:
        if digest_bits not in (224, 256, 384, 512):
            fail("ValueError: 'digest_bytes' must be: 224, 256, 384 or 512")
        digest_bytes = digest_bits // 8

    if kwargs:
        fail("TypeError: " + "Unknown parameters: " + str(kwargs))

    return Keccak_Hash(data, digest_bytes, update_after_digest)

Keccak = larky.struct(
    new=new,
    __name__ = 'Keccak',
)