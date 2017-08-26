// Converted from Javascript JScoord created by Jonathan Stott under GPL license
//
// http://www.jstott.me.uk/jscoord/

using Toybox.Math;
using Toybox.Lang;
using Toybox.System;

class ConversionErrorException extends Lang.Exception {
  var errorMessage;

  function initialize(message) {
    errorMessage = message;
    Exception.initialize();
  }

  function getErrorMessage() {
    return errorMessage;
  }
}

class CoordinateConverter {
  static const EQUATORIAL_RADIUS = 6378137d;
  static const POLAR_RADIUS = 6356752.314d;
  static const WGS84 = new ReferenceEllipsoid(EQUATORIAL_RADIUS, POLAR_RADIUS);
  // scale factor
  static const F0 = 0.9996d;

  static function latlongToUTM(latitude, longitude) {
    if (latitude < -90.0d || latitude > 90.0d || longitude < -180.0d
        || longitude >= 180.0d) {
      throw new ConversionErrorException(
          "Legal ranges: latitude [-90,90], longitude [-180,180).");
    }

    var longitudeZone = getLongZone(latitude, longitude);
    var latitudeRad = Math.toRadians(latitude);
    var longitudeRad = Math.toRadians(longitude);
    var longitudeOrigin = (longitudeZone - 1) * 6 - 180 + 3;
    var longitudeOriginRad = Math.toRadians(longitudeOrigin);

    var a = WGS84.major;
    var eSquared = WGS84.ecc;
    var ePrimeSquared = eSquared / (1 - eSquared);

    var n = a / Math.sqrt(1 - eSquared * Math.sin(latitudeRad) * Math.sin(latitudeRad));
    var t = Math.tan(latitudeRad) * Math.tan(latitudeRad);
    var c = ePrimeSquared * Math.cos(latitudeRad) * Math.cos(latitudeRad);
    var A = Math.cos(latitudeRad) * (longitudeRad - longitudeOriginRad);

    var m =
      a
        * ((1
          - eSquared / 4
          - 3 * eSquared * eSquared / 64
          - 5 * eSquared * eSquared * eSquared / 256)
          * latitudeRad
          - (3 * eSquared / 8
            + 3 * eSquared * eSquared / 32
            + 45 * eSquared * eSquared * eSquared / 1024)
            * Math.sin(2 * latitudeRad)
          + (15 * eSquared * eSquared / 256
            + 45 * eSquared * eSquared * eSquared / 1024)
            * Math.sin(4 * latitudeRad)
          - (35 * eSquared * eSquared * eSquared / 3072)
            * Math.sin(6 * latitudeRad));

    var easting =
      (F0
        * n
        * (A
          + (1 - t + c) * Math.pow(A, 3.0) / 6
          + (5 - 18 * t + t * t + 72 * c - 58 * ePrimeSquared)
            * Math.pow(A, 5.0)
            / 120)
        + 500000.0);

    var northing =
      (F0
        * (m
          + n
            * Math.tan(latitudeRad)
            * (A * A / 2
              + (5 - t + (9 * c) + (4 * c * c)) * Math.pow(A, 4.0) / 24
              + (61 - (58 * t) + (t * t) + (600 * c) - (330 * ePrimeSquared))
                * Math.pow(A, 6.0)
                / 720)));

    // Adjust for the southern hemisphere.
    if (latitude < 0.0) {
      northing += 10000000;
    }

    return {
      :longZone => longitudeZone,
      :latZone => LatZones.getZone(latitude),
      :northing => northing.toNumber(),
      :easting => easting.toNumber()
    };
  }

  static function getLongZone(latitude, longitude) {
    var longitudeZone = Math.floor((longitude + 180.0) / 6.0) + 1;
    // Special zone for Norway.
    if (latitude >= 56.0 && latitude < 64.0 && longitude >= 3.0
        && longitude < 12.0) {
      longitudeZone = 32;
    }
    // Special zones for Svalbard
    if (latitude >= 72.0 && latitude < 84.0) {
      if (longitude >= 0.0 && longitude < 9.0) {
        longitudeZone = 31;
      } else if (longitude >= 9.0 && longitude < 21.0) {
        longitudeZone = 33;
      } else if (longitude >= 21.0 && longitude < 33.0) {
        longitudeZone = 35;
      } else if (longitude >= 33.0 && longitude < 42.0) {
        longitudeZone = 37;
      }
    }
    return longitudeZone.toNumber();
  }

  static class ReferenceEllipsoid {
    var major;
    var minor;
    var ecc;

    function initialize(maj, min) {
      major = maj;
      minor = min;
      ecc = (major * major - minor * minor) / (major * major);
    }
  }

  static class LatZones {
    static const DEGRESS = [-90, -84, -72, -64, -56, -48, -40, -32, -24, -16,
                            -8, 0, 8, 16, 24, 32, 40, 48, 56, 64, 72, 84];
    static const NEG_DEGREES = [-90, -84, -72, -64, -56, -48, -40, -32, -24,
                                -16, -8];
    static const POS_DEGRESS = [0, 8, 16, 24, 32, 40, 48, 56, 64, 72, 84];
    static const NEG_LETTERS = [:A, :C, :D, :E, :F, :G, :H, :J, :K, :L, :M];
    static const POS_LETTERS = [:N, :P, :Q, :R, :S, :T, :U, :V, :W, :X, :Z];
    static const LETTERS_COUNT = NEG_LETTERS.size() + POS_LETTERS.size();

    static function getZone(latitude) {
      var latIndex = -2;
      if (latitude >= 0) {
        var len = POS_LETTERS.size();
        for (var i = 0; i < len; i++) {
          if (latitude == POS_DEGRESS[i]) {
            latIndex = i;
            break;
          }
          if (latitude > POS_DEGRESS[i]) {
            continue;
          } else {
            latIndex = i - 1;
            break;
          }
        }
      } else {
        var len = NEG_LETTERS.size();
        for (var i = 0; i < len; i++) {
          if (latitude == NEG_DEGREES[i]) {
            latIndex = i;
            break;
          }
          if (latitude < NEG_DEGREES[i]) {
            latIndex = i - 1;
            break;
          } else {
            continue;
          }
        }
      }
      if (latIndex == -1) {
        latIndex = 0;
      }
      if (latitude >= 0) {
        if (latIndex == -2) {
          latIndex = POS_LETTERS.size(); - 1;
        }
        return POS_LETTERS[latIndex];
      } else {
        if (latIndex == -2) {
          latIndex = NEG_LETTERS.size() - 1;
        }
        return NEG_LETTERS[latIndex];
      }
    }
  }
}
